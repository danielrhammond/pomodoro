//
//  AppDelegate.swift
//  Pomodoro
//
//  Created by Daniel Hammond on 1/4/16.
//  Copyright © 2016 danielrhammond. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private lazy var item: NSStatusItem = { NSStatusBar.systemStatusBar().statusItemWithLength(-1) }()
    private lazy var pomodoroController = PomodoroController()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        pomodoroController.menuTitleSignal.observe { [weak item] (title) in item?.title = title }
        pomodoroController.menuActionSignal.observe { [weak item] (actions) in
            item?.menu = NSMenu(actions: actions)
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

