//
//  AppDelegate.swift
//  RightSide
//
//  Created by Shota HAMADA on 2018/02/09.
//  Copyright © 2018 Shota HAMADA. All rights reserved.
//

import Cocoa
import Quartz

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    override init() {
        super.init()
        UserDefaults.standard.registerDefaults()
    }
}
