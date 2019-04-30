//
//  JoRefreshConstant+Active.swift
//  JoRefresh
//
//  Created by django on 7/24/17.
//  Copyright © 2017 django. All rights reserved.
//

import Foundation


// MARK: Pispatch

extension JoRefreshConstant {
    
    internal func panGestureRecognizerStateDidChanged(state: UIGestureRecognizer.State) {
        
        if state == .began {
            semaphore = 0
        }
        
        guard let scrollView = superview as? UIScrollView else {
            return
        }
        guard state != .changed, state != .began, !isRefreshing else {
            return
        }
        
        for index in 0...4 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + (0.5 + 0.25 * TimeInterval(index)), execute: {  [weak self] in
                if let unweak = self, scrollView.panGestureRecognizer.state != .changed, scrollView.panGestureRecognizer.state != .began, !unweak.isRefreshing  {
                    self?.setActive(view: self?.footer, state: false)
                    self?.setActive(view: self?.header, state: false)
                }
            })
        }
    }
    
    internal func scrollViewContentOffsetDidChanged(contentOffset: CGPoint) {
        
        guard let scrollView = superview as? UIScrollView else {
            return
        }
        
        if isRefreshing {
            if let header = header, header.isRefreshing {
                header.frame.origin.y = scrollView.contentOffset.y + contentInset.top - adjustedContentInset.top
            } else if let footer = footer, footer.isRefreshing {
                var maxY = scrollView.contentOffset.y + scrollView.frame.height - contentInset.bottom + adjustedContentInset.bottom
                maxY = max(scrollView.contentSize.height, maxY)
                footer.frame.origin.y = maxY - footer.frame.height
            }
        } else {
            
            let isLongContent: Bool = scrollView.contentSize.height > 0 &&
                scrollView.frame.height > 0 &&
                (scrollView.contentSize.height + contentInset.top + contentInset.bottom > scrollView.frame.height)
            
            let maxY: CGFloat = isLongContent ? scrollView.contentSize.height + contentInset.bottom : scrollView.frame.height - contentInset.top
            if let header = header,
                header.isEnabled,
                contentOffset.y + adjusted < -contentInset.top {
                setActive(view: header, state: true)
                setActive(view: footer, state: false)
                dispatchForHeader(header: header, scrollView: scrollView)
            } else if let footer = footer,
                footer.isEnabled,
                footerActiveMode == .toBottom,
                isLongContent,
                contentOffset.y + scrollView.frame.height + footerOffset > maxY {
                
                setActive(view: footer, state: true)
                setActive(view: header, state: false)
                dispatchForFooterToBottomMode(footer, scrollView: scrollView, isLongContent: isLongContent, maxY: maxY)
            } else if let footer = footer,
                footer.isEnabled,
                (contentOffset.y - adjusted > -contentInset.top && !isLongContent) ||
                    (contentOffset.y + scrollView.frame.height - adjusted > maxY && isLongContent) {
                
                setActive(view: footer, state: true)
                setActive(view: header, state: false)
                dispatchForFooter(footer, scrollView: scrollView, isLongContent: isLongContent, maxY: maxY)
            }
        }
    }
    
    internal func scrollViewContentSizeDidChanged(contentSize: CGSize) {

        if let header = header {
            superview?.addSubview(header)
            superview?.sendSubviewToBack(header)
        }
        
        if let footer = footer {
            superview?.addSubview(footer)
            superview?.sendSubviewToBack(footer)
        }
        
        if let tailer = tailer {
            superview?.addSubview(tailer)
            superview?.sendSubviewToBack(tailer)
        }
        
        tailer?.frame.origin.y = contentSize.height
    }
    
    private func dispatchForHeader(header: JoRefreshControl, scrollView: UIScrollView) {
        header.frame.origin.y = scrollView.contentOffset.y + contentInset.top - adjustedContentInset.top
        let percent = scrollView.isDragging ? max(0, min(1, abs(header.frame.origin.y) / (header.frame.height + headerOffset))) : header.refreshPercent
        header._updatePercent(percent)
        if !scrollView.isDragging, percent == 1, canRefresh {
            header.beginRefreshing()
        }
    }
    
    private func dispatchForFooterToBottomMode(_ footer: JoRefreshControl, scrollView: UIScrollView, isLongContent: Bool, maxY: CGFloat) {
        footer.frame.origin.y = scrollView.contentOffset.y + scrollView.frame.height - footer.frame.height - contentInset.bottom
        if !scrollView.isDragging, canRefresh {
            footer.beginRefreshing()
        }
    }
    
    private func dispatchForFooter(_ footer: JoRefreshControl, scrollView: UIScrollView, isLongContent: Bool, maxY: CGFloat) {
        footer.frame.origin.y = scrollView.contentOffset.y + scrollView.frame.height - footer.frame.height - contentInset.bottom
        let percent = scrollView.isDragging ? max(0, min(1, (footer.frame.maxY - maxY + contentInset.bottom) / (footer.frame.height + footerOffset))) : footer.refreshPercent
        footer._updatePercent(percent)
        if !scrollView.isDragging, percent == 1, canRefresh {
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
        
        guard (state == true && scrollView.isDragging) || (state == false)  else {
            return
        }
        
        if state {
            if view.isHidden {
                view.isHidden = false
                scrollView.addSubview(view)
                scrollView.sendSubviewToBack(view)
            }
        } else {
            if !view.isHidden {
                view.isHidden = true
                view.frame.origin = CGPoint.zero
            }
        }
    }
}

// MARK: JoRefreshControlRespond

extension JoRefreshConstant: JoRefreshControlRespond {
    
    func beginRefreshing(_ refreshControl: JoRefreshControl) {
        lastRefreshTime = Date().timeIntervalSince1970
        
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
        
        guard let view = refreshControl.superview, view == superview else {
            return
        }
        view.sendSubviewToBack(refreshControl)
        
        semaphore = 1
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

