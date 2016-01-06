//
//  MenuItem.swift
//  Pomodoro
//
//  Created by Daniel Hammond on 1/4/16.
//  Copyright © 2016 danielrhammond. All rights reserved.
//

import Cocoa

@objc class MenuAction: NSObject {
    typealias Action = MenuAction -> Void
    let title: String
    private(set) var action: Action?
    private(set) lazy var item: NSMenuItem = { return NSMenuItem(title: self.title, action: "act:", keyEquivalent: "") }()
    
    required init(title: String, action: Action?) {
        self.title = title
        self.action = action
        super.init()
        item.target = self
    }
    
    @objc private func act(item: NSMenuItem) {
        action?(self)
    }
}
