//
//  UIScrollView+JoRefresh.swift
//  JoRefresh
//
//  Created by django on 7/12/17.
//  Copyright © 2017 django. All rights reserved.
//

import UIKit
import ObjectiveC

fileprivate var JoRefreshConstantTargetKey: UInt8 = 0

public extension UIScrollView {
    
    // MARK: Member variable

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
