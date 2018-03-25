//
//  PullToRefreshConst.swift
//  JunctionProject3
//
//  Created by 塗木冴 on 2018/03/24.
//  Copyright © 2018年 SaeNuruki. All rights reserved.
//

import UIKit

struct PullToRefreshConst {
    static let pullTag = 810
    static let height: CGFloat = 40
    static let animationDuration: Double = 0.5
    static let fixedTop = true // PullToRefreshView fixed Top
}

public struct PullToRefreshOption {
    public var backgroundColor: UIColor
    public var indicatorColor: UIColor
    public var autoStopTime: Double // 0 is not auto stop
    public var fixedSectionHeader: Bool // Update the content inset for fixed section headers

    public init(backgroundColor: UIColor = .clear, indicatorColor: UIColor = .black, autoStopTime: Double = 0, fixedSectionHeader: Bool = false) {
        self.backgroundColor = backgroundColor
        self.indicatorColor = indicatorColor
        self.autoStopTime = autoStopTime
        self.fixedSectionHeader = fixedSectionHeader
    }
}
