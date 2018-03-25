//
//  UIScrollView+Extension.swift
//  JunctionProject3
//
//  Created by 塗木冴 on 2018/03/24.
//  Copyright © 2018年 SaeNuruki. All rights reserved.
//


import Foundation
import UIKit

public extension UIScrollView {

    fileprivate func refreshViewWithTag(_ tag:Int) -> PullToRefreshView? {
        let pullToRefreshView = viewWithTag(tag)
        return pullToRefreshView as? PullToRefreshView
    }

    public func addPullRefresh(options: PullToRefreshOption = PullToRefreshOption(), refreshCompletion :(() -> Void)?) {
        let refreshViewFrame = CGRect(x: 0, y: -PullToRefreshConst.height, width: self.frame.size.width, height: PullToRefreshConst.height)
        let refreshView = PullToRefreshView(options: options, frame: refreshViewFrame, refreshCompletion: refreshCompletion)
        refreshView.tag = PullToRefreshConst.pullTag
        addSubview(refreshView)
    }

    public func startPullRefresh() {
        let refreshView = self.refreshViewWithTag(PullToRefreshConst.pullTag)
        refreshView?.state = .refreshing
    }

    public func stopPullRefreshEver(_ ever:Bool = false) {
        let refreshView = self.refreshViewWithTag(PullToRefreshConst.pullTag)
        if ever {
            refreshView?.state = .finish
        } else {
            refreshView?.state = .stop
        }
    }

    public func removePullRefresh() {
        let refreshView = self.refreshViewWithTag(PullToRefreshConst.pullTag)
        refreshView?.removeFromSuperview()
    }
}

