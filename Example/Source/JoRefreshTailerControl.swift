//
//  JoRefreshTailerControl.swift
//  iOS Example
//
//  Created by django on 7/20/17.
//  Copyright © 2017 django. All rights reserved.
//

import UIKit
import JoRefresh

class JoRefreshTailerControl: JoRefreshControl {

    let lable: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(lable)
        lable.textColor = .black
        lable.textAlignment = .center
        lable.text = "没有更多"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lable.frame = bounds
        layer.borderWidth = 1
    }
}
