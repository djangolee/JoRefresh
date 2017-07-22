//
//  swift
//  JoRefresh
//
//  Created by django on 7/18/17.
//  Copyright © 2017 django. All rights reserved.
//

import UIKit

class JoRefreshConstant: UIView, JoRefreshConstantTarget {
    
    // MARK: Member variable
    
    static var JoRefreshConstantContext: UnsafeMutableRawPointer!
    static fileprivate let animatewithDuration: TimeInterval = 0.25
    
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
//            if #available(iOS 11.0, *) {
//                return scrollView?.adjustedContentInset ?? UIEdgeInsets.zero
//            } else {
//                return scrollView?.contentInset ?? UIEdgeInsets.zero
//            }
            return scrollView?.contentInset ?? UIEdgeInsets.zero
        }
    }
    
    var isRefreshing: Bool {
        get {
            return (header?.isRefreshing ?? false) || (footer?.isRefreshing ?? false)
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
                superview.insertSubview(newValue, at: 0)
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
                superview.insertSubview(newValue, at: 0)
            }
        }
    }
    
    private var _tailer: JoRefreshControl? = nil {
        didSet {
            oldValue?.removeFromSuperview()
            oldValue?.respondDelegate = nil
            tailerInset.bottom = 0
            if let newValue = _tailer, let superview = superview as? UIScrollView {
                newValue.frame.origin.y = superview.contentSize.height
                tailerInset.bottom = newValue.sizeThatFits(superview.frame.size).height
                superview.insertSubview(newValue, at: 0)
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
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .initial, context: JoRefreshConstant.JoRefreshConstantContext)
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: .initial, context: JoRefreshConstant.JoRefreshConstantContext)
    }
    
    private func unbringScrollViewKeyPathObserve(_ scrollView: UIScrollView) {
        let pan = scrollView.panGestureRecognizer
        pan.removeObserver(self, forKeyPath: #keyPath(UIGestureRecognizer.state), context: JoRefreshConstant.JoRefreshConstantContext)
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), context: JoRefreshConstant.JoRefreshConstantContext)
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), context: JoRefreshConstant.JoRefreshConstantContext)
    }
}

extension JoRefreshConstant {
    
    fileprivate func panGestureRecognizerStateDidChanged(state: UIGestureRecognizerState) {
        guard superview is UIScrollView else {
            return
        }
        
        if state != .changed, state != .began, !isRefreshing {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {  [weak self] in
                if state != .changed, state != .began, !(self?.isRefreshing ?? false) {
                    self?.setActive(view: self?.footer, state: false)
                    self?.setActive(view: self?.header, state: false)
                }
            })
        }
    }
    
    fileprivate func scrollViewContentOffsetDidChanged(contentOffset: CGPoint) {
        
        guard let scrollView = superview as? UIScrollView else {
            return
        }
        
        if isRefreshing {
            if let header = header, header.isRefreshing {
                header.frame.origin.y = scrollView.contentOffset.y + contentInset.top - adjustedContentInset.top
            } else if let footer = footer, footer.isRefreshing {
                footer.frame.origin.y = scrollView.contentOffset.y + scrollView.frame.height - footer.frame.height
            }
        } else {
            
            let isLongContent: Bool = scrollView.contentSize.height + contentInset.top + contentInset.bottom > scrollView.frame.height
            let maxY: CGFloat = isLongContent ? scrollView.contentSize.height + contentInset.bottom : scrollView.frame.height - contentInset.top
            if let header = header,
                contentOffset.y + adjusted < -contentInset.top {
                
                setActive(view: header, state: true)
                setActive(view: footer, state: false)
                dispatchForHeader(header: header, scrollView: scrollView)
            } else if let footer = footer,
                footerActiveMode == .toBottom,
                isLongContent,
                contentOffset.y + scrollView.frame.height + footerOffset > maxY {
                
                setActive(view: footer, state: true)
                setActive(view: header, state: false)
                dispatchForFooterToBottomMode(footer, scrollView: scrollView, isLongContent: isLongContent, maxY: maxY)
            } else if let footer = footer,
                (contentOffset.y - adjusted > -contentInset.top && !isLongContent) ||
                    (contentOffset.y + scrollView.frame.height - adjusted > maxY && isLongContent) {
                
                setActive(view: footer, state: true)
                setActive(view: header, state: false)
                dispatchForFooter(footer, scrollView: scrollView, isLongContent: isLongContent, maxY: maxY)
            }
        }
    }
    
    fileprivate func scrollViewContentSizeDidChanged(contentSize: CGSize) {
        if let tailer = tailer {
            tailer.frame.origin.y = contentSize.height
            superview?.insertSubview(tailer, at: 0)
        }
    }
    
    private func dispatchForHeader(header: JoRefreshControl, scrollView: UIScrollView) {
        header.frame.origin.y = scrollView.contentOffset.y + contentInset.top - adjustedContentInset.top
        let percent = scrollView.isDragging ? max(0, min(1, abs(header.frame.origin.y) / (header.frame.height + headerOffset))) : header.refreshPercent
        header._updatePercent(percent)
        if !scrollView.isDragging, percent == 1 {
            header.beginRefreshing()
        }
    }
    
    private func dispatchForFooterToBottomMode(_ footer: JoRefreshControl, scrollView: UIScrollView, isLongContent: Bool, maxY: CGFloat) {
        footer.frame.origin.y = scrollView.contentOffset.y + scrollView.frame.height - footer.frame.height
        footer._updatePercent(1.0)
        footer.beginRefreshing()
    }
    
    private func dispatchForFooter(_ footer: JoRefreshControl, scrollView: UIScrollView, isLongContent: Bool, maxY: CGFloat) {
        footer.frame.origin.y = scrollView.contentOffset.y + scrollView.frame.height - footer.frame.height
        let percent = scrollView.isDragging ? max(0, min(1, (footer.frame.maxY - maxY) / (footer.frame.height + footerOffset))) : footer.refreshPercent
        footer._updatePercent(percent)
        if !scrollView.isDragging, percent == 1 {
            footer.beginRefreshing()
        }
    }
    
    private func dispatchForTailer(_ tailer: JoRefreshControl, scrollView: UIScrollView) {
        tailer.frame.origin.y = scrollView.contentSize.height
    }
    
    fileprivate func setActive(view: JoRefreshControl?, state: Bool) {
        guard let view = view else {
            return
        }
        guard let scrollView = superview as? UIScrollView else {
            view.isHidden = true
            view.removeFromSuperview()
            return
        }
        if state {
            if view.isHidden {
                view.isHidden = false
                scrollView.insertSubview(view, at: 0)
            }
        } else {
            if !view.isHidden {
                view.isHidden = true
                view.frame.origin = CGPoint.zero
            }
        }
    }
}

extension JoRefreshConstant: JoRefreshControlRespond {
    
    func beginRefreshing(_ refreshControl: JoRefreshControl) {
        let controlHeight = refreshControl.sizeThatFits(self.superview?.frame.size ?? CGSize.zero).height
        if refreshControl == header, self.adjustedContentInset.top != controlHeight {
            UIView.animate(withDuration: JoRefreshConstant.animatewithDuration, animations: {
                self.adjustedContentInset.top = controlHeight
            })
        } else if refreshControl == footer, self.adjustedContentInset.bottom != controlHeight {
            UIView.animate(withDuration: JoRefreshConstant.animatewithDuration, animations: {
                self.adjustedContentInset.bottom = controlHeight
            })
        }
    }
    
    func endRefreshing(_ refreshControl: JoRefreshControl) {
        
        if refreshControl == header {
            UIView.animate(withDuration: JoRefreshConstant.animatewithDuration, animations: {
                if self.adjustedContentInset.top != 0 {
                    self.adjustedContentInset.top = 0
                    refreshControl.frame.origin.y = 0
                }
            }, completion: { (finish) in
                self.setActive(view: refreshControl, state: false)
            })
        } else if refreshControl == footer {
            UIView.animate(withDuration: JoRefreshConstant.animatewithDuration, animations: {
                if self.adjustedContentInset.bottom != 0 {
                    self.adjustedContentInset.bottom = 0
                }
            }, completion: { (finish) in
                self.setActive(view: refreshControl, state: false)
            })
        }
    }
    
    func refreshControlDidRespond(_ refreshControl: JoRefreshControl) {
        
    }
    
}

