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
                result.unionInPlace(.Resume)
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

func formatSeconds(seconds: Int) -> String {
    return "\(seconds)s"
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
