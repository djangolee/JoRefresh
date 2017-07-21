//
//  JoRefreshControl.swift
//  JoRefresh
//
//  Created by django on 7/12/17.
//  Copyright © 2017 django. All rights reserved.
//

import UIKit

open class JoRefreshControl: UIControl, UIScrollViewDelegate {
    
    internal private (set) var isResponding: Bool = false
    internal private (set) var refreshPercent: CGFloat = 0
    internal weak var respondDelegate: JoRefreshControlRespond? = nil
    
    open private (set) var isRefreshing: Bool = false {
        didSet {
            guard oldValue != isRefreshing else { return }
            
            if isRefreshing {
                refreshPercent = 1
                respondDelegate?.beginRefreshing(self)
                sendActions(for: .valueChanged)
            } else {
                refreshPercent = 0
                respondDelegate?.endRefreshing(self)
            }
        }
    }
    
    internal func _updatePercent(_ percent: CGFloat) {
        guard !isRefreshing else { return }
        refreshPercent = percent
        respondDelegate?.refreshControlDidRespond(self)
        updatePercent(percent)
    }
    
    open func updatePercent(_ percent: CGFloat) {
        
    }
    
    open func beginRefreshing() {
        isRefreshing = true
    }
    
    open func endRefreshing() {
        isRefreshing = false
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = superview {
            translatesAutoresizingMaskIntoConstraints = true
            frame.size.width = superview.frame.width
            frame.size.height = sizeThatFits(superview.frame.size).height
            autoresizingMask = .flexibleWidth
        }
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: superview?.frame.width ?? size.width, height: 60)
    }
}

internal protocol JoRefreshControlRespond: class {

    func refreshControlDidRespond(_ refreshControl: JoRefreshControl)
    func beginRefreshing(_ refreshControl: JoRefreshControl)
    func endRefreshing(_ refreshControl: JoRefreshControl)
    
}
