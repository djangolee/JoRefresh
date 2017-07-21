//
//  JoRefresh.swift
//  JoRefresh
//
//  Created by django on 7/21/17.
//  Copyright © 2017 django. All rights reserved.
//

import UIKit
import ObjectiveC

fileprivate var JoRefreshConstantTargetKey: UInt8 = 0

public extension UIScrollView {

    var joRefresh: JoRefreshConstantTarget {
        set { }
        get {
            var target = objc_getAssociatedObject(self, &JoRefreshConstantTargetKey) as? JoRefreshConstantTarget
            if target == nil {
                target = JoRefreshConstant()
                objc_setAssociatedObject(self, &JoRefreshConstantTargetKey, target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                addSubview(target as! UIView)
            }
            return target!;
        }
    }
}

public protocol JoRefreshConstantTarget {
    
    var header: JoRefreshControl? { get set }
    var footer: JoRefreshControl? { get set }
    var tailer: JoRefreshControl? { get set }
    
    var headerOffset: CGFloat { get set }
    var footerOffset: CGFloat { get set }
    var adjusted: CGFloat { get set }
    var footerActiveMode: JoRefreshFooterActiveMode { get set }
    
    func endRefreshing()
}

public enum JoRefreshFooterActiveMode: Int {
    case dragging
    case toBottom
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

