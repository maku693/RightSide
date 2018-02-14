//
//  AppDelegate.swift
//  DirectoryViewer
//
//  Created by Shota HAMADA on 2018/02/09.
//  Copyright © 2018年 Shota HAMADA. All rights reserved.
//

import Cocoa
import Quartz

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        showOpenPanelIfNecessay()
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }

    func showOpenPanelIfNecessay() {
        if DocumentController.shared.documents.count == 0 {
            DocumentController.shared.openDocument(self)
        }
    }

    func togglePreviewPanel() {
        if QLPreviewPanel.sharedPreviewPanelExists() && QLPreviewPanel.shared().isVisible {
            QLPreviewPanel.shared().orderOut(nil)
        } else {
            QLPreviewPanel.shared().makeKeyAndOrderFront(nil)
        }
    }

}

