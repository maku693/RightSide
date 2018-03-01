//
//  WindowController.swift
//  RightSide
//
//  Created by Shota HAMADA on 2018/02/22.
//  Copyright © 2018 Shota HAMADA. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        shouldCascadeWindows = true
    }
}
