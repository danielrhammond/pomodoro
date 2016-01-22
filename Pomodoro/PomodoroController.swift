//
//  PomodoroController.swift
//  Pomodoro
//
//  Created by Daniel Hammond on 1/5/16.
//  Copyright © 2016 danielrhammond. All rights reserved.
//

import Foundation
import RxSwift

let WORK_DURATION = 25*60
let BREAK_DURATION = 5*60
private let DEFAULT_STATE = StatusBarState.WaitingWork(WORK_DURATION)

class PomodoroController {
    // MARK: Public Properties
    let menuActionSignal: Observable<[MenuAction]>
    let menuTitleSignal: Observable<String>
    let stateSignal: Observable<StatusBarState>
    // MARK: Private Properties
    
    private(set) var Variable<StatusBarState> = DEFAULT_STATE {
        didSet {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            let capturedState = state
            dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                guard let state = self?.state where state == capturedState else { return }
                if let next = state.nextTick {
                    self?.state = next
                    if case .WaitingBreak = next {
                        self?.successfulCount++
                    }
                }
            }
            stateSignal.
            stateSignal.update(state)
        }
    }
    private var actions = [MenuAction]() {
        didSet {
            menuActionSignal.update(actions)
        }
    }
    private var successfulCount: Int = 0 {
        didSet {
            actions = actionsForState(state)
        }
    }
    
    // MARK: Init
    required init() {
        menuTitleSignal = stateSignal.map { state in return state.title }
        menuActionSignal = stateSignal.map { state in return self.actionsForState(state) }
        state.nextSkip
        let v = Variable<StatusBarState>(DEFAULT_STATE)
        stateSignal.update(state)
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
        menuActions.append(MenuAction(title: "Success: \(successfulCount)", action: nil))
        menuActions.append(MenuAction(title: "Quit", action: { _ in exit(EXIT_SUCCESS) }))
        return menuActions
    }
}
