//
//  JoRefreshConstantTarget.swift
//  JoRefresh
//
//  Created by django on 7/18/17.
//  Copyright © 2017 django. All rights reserved.
//

import UIKit

public protocol JoRefreshConstantTarget {
    
    var header: JoRefreshControl? { get set }
    var footer: JoRefreshControl? { get set }
    var tailer: JoRefreshControl? { get set }
    
    var offset: CGFloat { get set }
    var adjusted: CGFloat { get set }
    var isRefreshing: Bool { get }
    var headerOfPercent: CGFloat { get }
    var footererOfPercent: CGFloat { get }
    
    func beginRefreshing()
    func endRefreshing()
}

extension JoRefreshConstantTarget {

    func beginRefreshing() { }
    func endRefreshing() { }
    
}

internal func + (lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsets(top: lhs.top + rhs.top, left: lhs.left + rhs.left, bottom: lhs.bottom + rhs.bottom, right: lhs.right + rhs.right)
}

internal func - (lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsets(top: lhs.top - rhs.top, left: lhs.left - rhs.left, bottom: lhs.bottom - rhs.bottom, right: lhs.right - rhs.right)
}

internal func += (lhs: inout UIEdgeInsets, rhs: UIEdgeInsets) -> Swift.Void {
    lhs = lhs + rhs
}

internal func -= (lhs: inout UIEdgeInsets, rhs: UIEdgeInsets) -> Swift.Void {
    lhs = lhs - rhs
}

