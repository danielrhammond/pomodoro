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

struct Actions : OptionSetType {
    let rawValue : Int
    static let Start = Actions(rawValue: 1 << 1)
    static let Pause = Actions(rawValue: 1 << 2)
    static let Resume = Actions(rawValue: 1 << 3)
    static let Skip = Actions(rawValue: 1 << 4)
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

    var title: String {
        get {
            switch self {
            case .WaitingWork:
                return "Work Time!"
            case .WaitingBreak:
                return "Break Time!"
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
            if duration > 1 {
                return .OnBreak(duration-1)
            } else {
                return .WaitingWork(WORK_DURATION)
            }
        case .OnWork:
            if duration > 1 {
                return .OnWork(duration-1)
            } else {
                return .WaitingBreak(BREAK_DURATION)
            }
        default:
            return nil
        }
    }
    
    var nextSkip: StatusBarState? {
        switch self {
        case .PausedWork, .PausedBreak, .WaitingBreak, .OnBreak, .OnWork:
            return .WaitingWork(WORK_DURATION)
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

    var pausedState: StatusBarState? {
        switch self {
        case .OnBreak(let d):
            return .PausedBreak(d)
        case .OnWork(let d):
            return .PausedWork(d)
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
    
    var actions: Actions {
        get {
            var result = Actions()
            if startedState != nil {
                result.unionInPlace(.Start)
            }
            if pausedState != nil {
                result.unionInPlace(.Pause)
            }
            if resumedState != nil {
                result.unionInPlace(.Resume)
            }
            if nextSkip != nil {
                result.unionInPlace(.Skip)
            }
            return result
        }
    }
}

private func formatSeconds(seconds: Int) -> String {
    let date = NSDate()
    let endDate = NSDate(timeIntervalSinceNow: Double(seconds))
    let components = NSCalendar.currentCalendar().components([.Minute, .Second], fromDate: date, toDate: endDate, options: NSCalendarOptions(rawValue: 0))
    return "\(components.minute):\(components.second/10)\(components.second%10)"
}

func ==(a: StatusBarState, b: StatusBarState) -> Bool {
    switch a {
    case .WaitingWork(let a):
        if case .WaitingWork(let b) = b {
            return a == b
        }
    case .PausedWork(let a):
        if case .PausedWork(let b) = b {
            return a == b
        }
    case .OnWork(let a):
        if case .OnWork(let b) = b {
            return a == b
        }
    case .WaitingBreak(let a):
        if case .WaitingBreak(let b) = b {
            return a == b
        }
    case .PausedBreak(let a):
        if case .PausedBreak(let b) = b {
            return a == b
        }
    case .OnBreak(let a):
        if case .OnBreak(let b) = b {
            return a == b
        }
    }
    return false
}
