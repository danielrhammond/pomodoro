//
//  Menu.swift
//  Pomodoro
//
//  Created by Daniel Hammond on 1/5/16.
//  Copyright © 2016 danielrhammond. All rights reserved.
//

import Cocoa

extension NSMenu {
    convenience init(actions: [MenuAction]) {
        self.init()
        for action in actions {
            addItem(action.item)
        }
    }
}
