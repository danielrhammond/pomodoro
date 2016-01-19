//
//  AudioController.swift
//  Pomodoro
//
//  Created by Daniel Hammond on 1/18/16.
//  Copyright © 2016 danielrhammond. All rights reserved.
//

import AppKit

class AudioController {
    private lazy var sound: NSSound? = {
        NSSound(contentsOfURL: NSBundle.mainBundle().URLForResource("Mute_Metal", withExtension: "aiff")!, byReference: false)
        }()
    func playAlert() {
        sound!.play()
    }
}
