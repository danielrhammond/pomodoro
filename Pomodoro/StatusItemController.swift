//
//  StatusItemController.swift
//  Pomodoro
//
//  Created by Daniel Hammond on 1/4/16.
//  Copyright © 2016 danielrhammond. All rights reserved.
//

import Cocoa

enum StatusBarState {
    case Waiting(Int)
    case Paused(Int)
    case On(Int)
}

extension StatusBarState {
    var menuActions: [MenuAction] {
        get {
            switch self {
            case .Waiting(let duration):
                let start = MenuAction(title: "Start", action: { _ in print("start: \(duration)") })
                return [start]
            default:
                return []
            }
        }
    }
}

extension StatusBarState {
    var title: String {
        get {
            switch self {
            case .Waiting(let duration):
                return "Waiting \(formatSeconds(duration))"
            case .Paused(let duration):
                return "Paused \(formatSeconds(duration))"
            case .On(let duration):
                return "\(formatSeconds(duration))"
            }
        }
    }
}

func formatSeconds(seconds: Int) -> String {
    return "\(seconds)s"
}

let item = MenuAction(title: "Foobar", action: { _ in print("in action block ok?") })

func menuForState(state: StatusBarState) -> NSMenu? {
    print("returning menu for state \(state)")
    let menu = NSMenu()
    menu.addItem(item.item)
    menu.itemArray.first?.enabled = true
    return menu
}
