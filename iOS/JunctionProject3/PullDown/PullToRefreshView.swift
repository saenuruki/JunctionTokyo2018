//
//  PullToRefreshView.swift
//  JunctionProject3
//
//  Created by 塗木冴 on 2018/03/24.
//  Copyright © 2018年 SaeNuruki. All rights reserved.
//


import UIKit

class PullToRefreshView: UIView {
    enum PullToRefreshState {
        case pulling     // 初めの状態
        case triggered   // 一定の高さを超え indicatorが回り始める
        case refreshing  // データの読み込みを開始する
        case stop        // indicatorの回転を止める
        case finish      // 読み込み終了時
    }

    // MARK: Variables
    let contentOffsetKeyPath = "contentOffset"
    let contentSizeKeyPath = "contentSize"
    var kvoContext = "PullToRefreshKVOContext"

    fileprivate var refreshOptions: PullToRefreshOption
    fileprivate var backgroundView: UIView
    fileprivate var indicator: UIActivityIndicatorView
    fileprivate var scrollViewInsets: UIEdgeInsets = UIEdgeInsets.zero
    fileprivate var refreshCompletion: (() -> Void)?
    fileprivate var pull: Bool = true

    fileprivate var positionY:CGFloat = 0 {
        didSet {
            if self.positionY == oldValue {
                return
            }
            var frame = self.frame
            frame.origin.y = positionY
            self.frame = frame
        }
    }

    var state: PullToRefreshState = PullToRefreshState.pulling {
        didSet {
            if self.state == oldValue {
                return
            }
            switch self.state {
            case .pulling:
                setPulling()
            case .triggered:
                startAnimating()
            case .refreshing:
                startRefresh()
            case .stop:
                stopAnimating()
            case .finish:
                var duration = PullToRefreshConst.animationDuration
                var time = DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    self.stopAnimating()
                }
                duration *= 2
                time = DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    self.removeFromSuperview()
                }
            }
        }
    }

    // MARK: UIView
    public override convenience init(frame: CGRect) {
        self.init(options: PullToRefreshOption(),frame:frame, refreshCompletion:nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(options: PullToRefreshOption, frame: CGRect, refreshCompletion :(() -> Void)?, down:Bool=true) {
        self.refreshOptions = options
        self.refreshCompletion = refreshCompletion

        self.backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        self.backgroundView.backgroundColor = self.refreshOptions.backgroundColor
        self.backgroundView.autoresizingMask = UIViewAutoresizing.flexibleWidth

        self.indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.indicator.bounds =  CGRect(x: 0, y: 0, width: 30, height: 30)
        self.indicator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        self.indicator.hidesWhenStopped = true
        self.indicator.color = options.indicatorColor
        self.pull = down

        super.init(frame: frame)
        self.addSubview(indicator)
        self.addSubview(backgroundView)
        self.autoresizingMask = .flexibleWidth
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.indicator.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
    }

    override func willMove(toSuperview superView: UIView!) {
        self.removeRegister()
        guard let scrollView = superView as? UIScrollView else {
            return
        }
        scrollView.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .initial, context: &kvoContext)
        if !pull {
            scrollView.addObserver(self, forKeyPath: contentSizeKeyPath, options: .initial, context: &kvoContext)
        }
    }

    fileprivate func removeRegister() {
        if let scrollView = superview as? UIScrollView {
            scrollView.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &kvoContext)
            if !pull {
                scrollView.removeObserver(self, forKeyPath: contentSizeKeyPath, context: &kvoContext)
            }
        }
    }

    deinit {
        self.removeRegister()
    }

    // MARK: KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let scrollView = object as? UIScrollView else {
            return
        }
        if keyPath == contentSizeKeyPath {
            self.positionY = scrollView.contentSize.height
            return
        }

        // Pulling State Check
        let offsetY = scrollView.contentOffset.y

        if offsetY <= 0 {
            if !self.pull {
                return
            }

            if offsetY < -self.frame.size.height {
                // pulling or refreshing
                if scrollView.isDragging == false && self.state != .refreshing { //release the finger
                    self.state = .refreshing //startAnimating
                } else if self.state != .refreshing { //reach the threshold
                    self.state = .triggered
                }
            } else if self.state == .triggered {
                //starting point, start from pulling
                self.state = .pulling
            }
            return //return for pull down
        }

        //push up
        let upHeight = offsetY + scrollView.frame.size.height - scrollView.contentSize.height
        if upHeight > 0 {
            // pulling or refreshing
            if self.pull {
                return
            }
            if upHeight > self.frame.size.height {
                // pulling or refreshing
                if scrollView.isDragging == false && self.state != .refreshing { //release the finger
                    self.state = .refreshing //startAnimating
                } else if self.state != .refreshing { //reach the threshold
                    self.state = .triggered
                }
            } else if self.state == .triggered  {
                //starting point, start from pulling
                self.state = .pulling
            }
        }
    }
}

fileprivate extension PullToRefreshView {

    fileprivate func setPulling() {
        if indicator.isAnimating {
            indicator.stopAnimating()
        }
    }

    fileprivate func startRefresh() {
        guard let scrollView = superview as? UIScrollView else {
            return
        }
        scrollViewInsets = scrollView.contentInset

        var insets = scrollView.contentInset
        if pull {
            insets.top += self.frame.size.height
        } else {
            insets.bottom += self.frame.size.height
        }
        scrollView.bounces = false
        UIView.animate(withDuration: PullToRefreshConst.animationDuration,
                       delay: 0,
                       options:[],
                       animations: {
                        scrollView.contentInset = insets
        },
                       completion: { _ in
                        if self.refreshOptions.autoStopTime != 0 {
                            let time = DispatchTime.now() + Double(Int64(self.refreshOptions.autoStopTime * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                            DispatchQueue.main.asyncAfter(deadline: time) {
                                self.state = .stop
                            }
                        }
                        self.refreshCompletion?()
        })
    }

    fileprivate func startAnimating() {
        indicator.startAnimating()
    }

    fileprivate func stopAnimating() {
        indicator.stopAnimating()
        guard let scrollView = superview as? UIScrollView else {
            return
        }
        scrollView.bounces = true
        let duration = PullToRefreshConst.animationDuration
        UIView.animate(withDuration: duration,
                       animations: {
                        scrollView.contentInset = self.scrollViewInsets
        }, completion: { _ in
            self.state = .pulling
        })
    }
}

