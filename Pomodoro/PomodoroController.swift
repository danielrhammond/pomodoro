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
    private let timer = Observable<Int>.timer(0.0, period: 1.0, scheduler: MainScheduler.instance)
    private lazy var nextState: Observable<StatusBarState> = {
        self.timer.map({ _ -> StatusBarState? in
            if let next = self.state.value.nextTick {
                return next
            }
            return nil
        }).filter({ $0 != nil }).map({ $0! })
    }()
    
    // MARK: Init
    required init() {
        nextState.subscribeNext({ [weak self] state in
            self?.automaticStateVariable.value = state
            self?.state.value = state
        }).addDisposableTo(bag)
    }
}
