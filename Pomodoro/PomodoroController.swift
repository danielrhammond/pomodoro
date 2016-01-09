//
//  PomodoroController.swift
//  Pomodoro
//
//  Created by Daniel Hammond on 1/5/16.
//  Copyright © 2016 danielrhammond. All rights reserved.
//

import Foundation

let WORK_DURATION = 25*60
let BREAK_DURATION = 5*60
private let DEFAULT_STATE = StatusBarState.WaitingWork(WORK_DURATION)

class PomodoroController {
    // MARK: Public Properties
    let menuActionSignal = Signal<[MenuAction]>()
    let menuTitleSignal = Signal<String>()
    // MARK: Private Properties
    private(set) var state = DEFAULT_STATE {
        didSet {
            if oldValue.actions != state.actions {
                actions = actionsForState(state)
            }
            menuTitleSignal.fire(state.title)
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            let capturedState = state
            dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                guard let state = self?.state where state == capturedState else { return }
                if let next = state.nextTick {
                    self?.state = next
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
        var menuActions = [MenuAction]()
        if state.actions.contains(.Start) {
            menuActions.append(MenuAction(title: "Start", action: { [weak self] _ in self?.state = (self?.state.startedState!)! }))
        }
        if state.actions.contains(.Pause) {
            menuActions.append(MenuAction(title: "Pause", action: { [weak self] _ in self?.state = (self?.state.pausedState!)! }))
        }
        if state.actions.contains(.Resume) {
            menuActions.append(MenuAction(title: "Resume", action: { [weak self] _ in self?.state = (self?.state.resumedState!)! }))
        }
        if state.actions.contains(.Skip) {
            menuActions.append(MenuAction(title: "Skip", action: { [weak self] _ in self?.state = (self?.state.nextSkip!)! }))
        }
        return menuActions
    }
}
