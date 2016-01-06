//
//  PomodoroController.swift
//  Pomodoro
//
//  Created by Daniel Hammond on 1/5/16.
//  Copyright © 2016 danielrhammond. All rights reserved.
//

import Foundation

private let DEFAULT_STATE = StatusBarState.Waiting(10)

class PomodoroController {
    // MARK: Public Properties
    let menuActionSignal = Signal<[MenuAction]>()
    let menuTitleSignal = Signal<String>()
    // MARK: Private Properties
    private(set) var state = DEFAULT_STATE {
        didSet {
            actions = actionsForState(state)
            menuTitleSignal.fire(state.title)
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                if let state = self?.state, case .On(let duration) = state {
                    if duration > 0 {
                        self?.state = .On(duration-1)
                    } else {
                        self?.state = .Waiting(10)
                    }
                }
            }
        }
    }
    private var actions = [MenuAction]() {
        didSet {
            menuActionSignal.fire(actions)
        }
    }
    // MARK: Init
    required init() {
        actions = actionsForState(state)
        menuActionSignal.fire(actions)
        menuTitleSignal.fire(state.title)
    }
    
    // MARK: Menu Actions
    private func actionsForState(state: StatusBarState) -> [MenuAction] {
        switch state {
        case .Waiting(let duration):
            let start = MenuAction(title: "Start", action: { [weak self] _ in
                self?.state = .On(duration)
            })
            return [start]
        case .On(let duration):
            let pause = MenuAction(title: "Pause", action: { [weak self] _ in
                self?.state = .Paused(duration)
            })
            return [pause]
        case .Paused(let duration):
            let resume = MenuAction(title: "Resume", action: { [weak self] _ in
                self?.state = .On(duration)
            })
            return [resume]
        }

    }
}
