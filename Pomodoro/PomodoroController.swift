//
//  PomodoroController.swift
//  Pomodoro
//
//  Created by Daniel Hammond on 1/5/16.
//  Copyright © 2016 danielrhammond. All rights reserved.
//

import Foundation

private let DEFAULT_STATE = StatusBarState.WaitingWork(10)

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
                guard let state = self?.state else { return }
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
        if let startedState = state.startedState {
            menuActions.append(MenuAction(title: "Start", action: { [weak self] _ in self?.state = startedState }))
        }
        if let resumedState = state.resumedState {
            menuActions.append(MenuAction(title: "Resume", action: { [weak self] _ in self?.state = resumedState }))
        }
        if let skippedState = state.nextSkip {
            menuActions.append(MenuAction(title: "Skip", action: { [weak self] _ in self?.state = skippedState }))
        }
        return menuActions
    }
}
