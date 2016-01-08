//
//  StatusItemController.swift
//  Pomodoro
//
//  Created by Daniel Hammond on 1/4/16.
//  Copyright © 2016 danielrhammond. All rights reserved.
//

import Cocoa

enum StatusBarState {
    case WaitingWork(Int)
    case PausedWork(Int)
    case OnWork(Int)
    case WaitingBreak(Int)
    case PausedBreak(Int)
    case OnBreak(Int)
}

extension StatusBarState {
    var duration: Int {
        get {
            switch self {
            case .WaitingWork(let d):
                return d
            case .PausedWork(let d):
                return d
            case .OnWork(let d):
                return d
            case .WaitingBreak(let d):
                return d
            case .PausedBreak(let d):
                return d
            case .OnBreak(let d):
                return d
            }
        }
    }

    var menuActions: [MenuAction] {
        get {
            switch self {
            case .WaitingWork, .WaitingBreak:
                let duration = self.duration
                let start = MenuAction(title: "Start", action: { _ in print("start: \(duration)") })
                return [start]
            default:
                return []
            }
        }
    }

    var title: String {
        get {
            switch self {
            case .WaitingWork, .WaitingBreak:
                let duration = self.duration
                return "Waiting \(formatSeconds(duration))"
            case .PausedWork, .PausedBreak:
                let duration = self.duration
                return "Paused \(formatSeconds(duration))"
            case .OnWork(let duration):
                return "Work: \(formatSeconds(duration))"
            case .OnBreak(let duration):
                return "Break: \(formatSeconds(duration))"
            }
        }
    }
    
    var nextTick: StatusBarState? {
        switch self {
        case .OnBreak:
            if duration > 0 {
                return .OnBreak(duration-1)
            } else {
                return .WaitingWork(10)
            }
        case .OnWork:
            if duration > 0 {
                return .OnWork(duration-1)
            } else {
                return .WaitingBreak(10)
            }
        default:
            return nil
        }
    }
    
    var nextSkip: StatusBarState? {
        switch self {
        case .PausedWork, .PausedBreak, .WaitingBreak, .OnBreak, .OnWork:
            return .WaitingWork(10)
        default:
            return nil
        }
    }

    var resumedState: StatusBarState? {
        switch self {
        case .PausedWork(let d):
            return .OnWork(d)
        case .PausedBreak(let d):
            return .OnBreak(d)
        default:
            return nil
        }
    }

    var startedState: StatusBarState? {
        switch self {
        case .WaitingWork(let d):
            return .OnWork(d)
        case .WaitingBreak(let d):
            return .OnBreak(d)
        default:
            return nil
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
