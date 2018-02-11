//
//  ViewController.swift
//  DirectoryViewer
//
//  Created by Shota HAMADA on 2018/02/09.
//  Copyright © 2018年 Shota HAMADA. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    @objc dynamic var directoryEntries = [DirectoryEntry]()

    override func viewDidLoad() {
        super.viewDidLoad()

        directoryEntries = DirectoryEntry.entries(for: FileManager.default.homeDirectoryForCurrentUser)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

