//
//  swift
//  JoRefresh
//
//  Created by django on 7/18/17.
//  Copyright © 2017 django. All rights reserved.
//

import UIKit

internal class JoRefreshConstant: UIView, JoRefreshConstantTarget {
    
    // MARK: Member variable
    
    static internal var JoRefreshConstantContext: UnsafeMutableRawPointer!
    static internal let animatewithDuration: TimeInterval = 0.25
    
    internal var semaphore: Int = 1
    internal var lastRefreshTime: TimeInterval = 0
    var minRefreshInterval: TimeInterval = 2
    
    weak var scrollView: UIScrollView? = nil
    
    var header: JoRefreshControl? {
        get { return _header }
        set { _header = newValue }
    }
    
    var footer: JoRefreshControl? {
        get { return _footer }
        set { _footer = newValue }
    }
    
    var tailer: JoRefreshControl? {
        get { return _tailer }
        set { _tailer = newValue }
    }
    
    
    var headerOffset: CGFloat = 60
    var footerOffset: CGFloat = 60
    var adjusted: CGFloat = 3
    
    var adjustedContentInset: UIEdgeInsets = UIEdgeInsets.zero {
        willSet {
            if let scrollView = superview as? UIScrollView {
                scrollView.contentInset -= adjustedContentInset
            }
        }
        didSet {
            if let scrollView = superview as? UIScrollView {
                scrollView.contentInset += adjustedContentInset
            }
        }
    }
    
    var tailerInset: UIEdgeInsets = UIEdgeInsets.zero {
        willSet {
            if let scrollView = superview as? UIScrollView {
                scrollView.contentInset -= tailerInset
            }
        }
        didSet {
            if let scrollView = superview as? UIScrollView {
                scrollView.contentInset += tailerInset
            }
        }
    }
    
    var contentInset: UIEdgeInsets {
        get {
            if #available(iOS 11.0, *) {
                return scrollView?.adjustedContentInset ?? UIEdgeInsets.zero
            } else {
                return scrollView?.contentInset ?? UIEdgeInsets.zero
            }
        }
    }
    
    var isRefreshing: Bool {
        get {
            return (header?.isRefreshing ?? false) || (footer?.isRefreshing ?? false)
        }
    }
    
    var canRefresh: Bool {
        get {
            if lastRefreshTime + minRefreshInterval < Date().timeIntervalSince1970 && semaphore == 0 && !isRefreshing {
                return true
            } else {
                return false
            }
        }
    }
    
    var footerActiveMode: JoRefreshFooterActiveMode = .dragging
    
    private var _header: JoRefreshControl? = nil {
        didSet {
            oldValue?.removeFromSuperview()
            oldValue?.respondDelegate = nil
            if let newValue = _header, let superview = superview as? UIScrollView {
                newValue.respondDelegate = self
                newValue.isHidden = true
                superview.addSubview(newValue)
            }
        }
    }
    
    private var _footer: JoRefreshControl? = nil {
        didSet {
            oldValue?.removeFromSuperview()
            oldValue?.respondDelegate = nil
            if let newValue = _footer, let superview = superview as? UIScrollView {
                newValue.respondDelegate = self
                newValue.isHidden = true
                superview.addSubview(newValue)
            }
        }
    }
    
    private var _tailer: JoRefreshControl? = nil {
        didSet {
            oldValue?.removeFromSuperview()
            oldValue?.respondDelegate = nil
            tailerInset.bottom = 0
            if let newValue = _tailer, let superview = superview as? UIScrollView {
                superview.addSubview(newValue)
                tailerInset.bottom = newValue.frame.height
            }
        }
    }
    
    func endRefreshing() {
        header?.endRefreshing()
        footer?.endRefreshing()
    }
    
    // MARK: Override
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame.size = CGSize.zero
        self.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        guard let superview = superview as? UIScrollView else {
            if let scrollView = scrollView {
                unbringScrollViewKeyPathObserve(scrollView)
            }
            return
        }
        
        scrollView = superview
        if (window != nil) {
            bringScrollViewKeyPathObserve(superview)
        } else {
            unbringScrollViewKeyPathObserve(superview)
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard  JoRefreshConstant.JoRefreshConstantContext == context else {
            return
        }
        
        if #keyPath(UIScrollView.contentOffset) == keyPath,
            let scrollView = object as? UIScrollView,  scrollView == superview {
            
            scrollViewContentOffsetDidChanged(contentOffset: scrollView.contentOffset)
        } else if #keyPath(UIScrollView.contentSize) == keyPath,
            let scrollView = object as? UIScrollView,  scrollView == superview {
            
            scrollViewContentSizeDidChanged(contentSize: scrollView.contentSize)
        } else if #keyPath(UIGestureRecognizer.state) == keyPath,
            let scrollView = superview as? UIScrollView {
            
            panGestureRecognizerStateDidChanged(state: scrollView.panGestureRecognizer.state)
        }
    }
    
    private func bringScrollViewKeyPathObserve(_ scrollView: UIScrollView) {
        let pan = scrollView.panGestureRecognizer
        pan.addObserver(self, forKeyPath: #keyPath(UIGestureRecognizer.state), options: .new, context: JoRefreshConstant.JoRefreshConstantContext)
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .new, context: JoRefreshConstant.JoRefreshConstantContext)
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: .initial, context: JoRefreshConstant.JoRefreshConstantContext)
    }
    
    private func unbringScrollViewKeyPathObserve(_ scrollView: UIScrollView) {
        let pan = scrollView.panGestureRecognizer
        pan.removeObserver(self, forKeyPath: #keyPath(UIGestureRecognizer.state), context: JoRefreshConstant.JoRefreshConstantContext)
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), context: JoRefreshConstant.JoRefreshConstantContext)
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), context: JoRefreshConstant.JoRefreshConstantContext)
    }
}
