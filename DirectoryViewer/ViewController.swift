//
//  ViewController.swift
//  DirectoryViewer
//
//  Created by Shota HAMADA on 2018/02/09.
//  Copyright © 2018年 Shota HAMADA. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @objc dynamic var directoryEntries = [DirectoryEntry]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Dummy data
        directoryEntries = [
            DirectoryEntry(
                title: "Node A",
                image: NSImage(named: .folder),
                children: []
            ),
            DirectoryEntry(
                title: "Node B",
                image: NSImage(named: .folder),
                children: [
                    DirectoryEntry(
                        title: "Child A",
                        image: NSImage(named: .folder),
                        children: []
                    ),
                    DirectoryEntry(
                        title: "Child A",
                        image: NSImage(named: .folder),
                        children: []
                    ),
                ]
            ),
        ]
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

