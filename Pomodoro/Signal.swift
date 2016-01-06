//
//  Signal.swift
//  Pomodoro
//
//  Created by Daniel Hammond on 1/5/16.
//  Copyright © 2016 danielrhammond. All rights reserved.
//

import Foundation

/// Hillariously simple and not threadsafe implementation
class Signal<T> {
    typealias Action = T -> Void
    private var observers = [Action]()
    private var last: T? = nil
    func fire(value: T) {
        last = value
        observers.forEach { $0(value) }
    }
    
    func observe(action: Action) {
        if let last = last {
            action(last)
        }
        observers.append(action)
    }
}
