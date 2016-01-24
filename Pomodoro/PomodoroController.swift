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
private let DEFAULT_STATE =
StatusBarState.WaitingWork(WORK_DURATION)

class PomodoroController {
    // MARK: Public Properties
    lazy var menuTitleSignal: Observable<String> = { self.state.asObservable().map({ state in return state.title }) }()
    lazy var menuActionSignal: Observable<[MenuAction]> = {
        self.state.asObservable().map({ state in return state.actions }).distinctUntilChanged().map { actions in
            var menuActions = [MenuAction]()
            if actions.contains(.Start) {
                menuActions.append(MenuAction(title: "Start", action: { [weak self] _ in self?.state.value = (self?.state.value.startedState!)! }))
            }
            if actions.contains(.Pause) {
                menuActions.append(MenuAction(title: "Pause", action: { [weak self] _ in self?.state.value = (self?.state.value.pausedState!)! }))
            }
            if actions.contains(.Resume) {
                menuActions.append(MenuAction(title: "Resume", action: { [weak self] _ in self?.state.value = (self?.state.value.resumedState!)! }))
            }
            if actions.contains(.Skip) {
                menuActions.append(MenuAction(title: "Skip", action: { [weak self] _ in self?.state.value = (self?.state.value.nextSkip!)! }))
            }
            //menuActions.append(MenuAction(title: "Success: \(successfulCount)", action: nil))
            menuActions.append(MenuAction(title: "Quit", action: { _ in exit(EXIT_SUCCESS) }))
            self.actions = menuActions
            return menuActions
        }
    }()
    private (set) lazy var automaticState: Observable<StatusBarState> = { self.automaticStateVariable.asObservable() }()
    private let automaticStateVariable = Variable<StatusBarState>(DEFAULT_STATE)
    let state = Variable<StatusBarState>(DEFAULT_STATE)
    // MARK: Private Properties
    private var actions = [MenuAction]()
    private let bag = DisposeBag()
    
    // MARK: Init
    required init() {
        state.asObservable().subscribeNext({ [weak self] state in
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            let capturedState = state
            dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                guard let state = self?.state where state.value == capturedState else { return }
                if let next = state.value.nextTick {
                    self?.automaticStateVariable.value = next
                    self?.state.value = next
                }
            }
        }).addDisposableTo(bag)
    }
}
