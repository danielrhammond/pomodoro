//
//  AppDelegate.swift
//  Pomodoro
//
//  Created by Daniel Hammond on 1/4/16.
//  Copyright © 2016 danielrhammond. All rights reserved.
//

import Cocoa
import RxSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private lazy var item: NSStatusItem = { NSStatusBar.systemStatusBar().statusItemWithLength(-1) }()
    private lazy var pomodoroController = PomodoroController()
    private lazy var audioController = AudioController()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        pomodoroController.menuTitleSignal.subscribeNext { [weak item] (title) -> Void in
            item?.title = title
        }
        

        
        pomodoroController.menuActionSignal.next {[weak item] (actions) in
            item?.menu = NSMenu(actions: actions)
        }
        pomodoroController.stateSignal.next { [weak audioController] state in
            switch state {
            case .WaitingBreak, .WaitingWork:
                audioController?.playAlert()
            default:
                break
            }
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}
