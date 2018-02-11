//
//  Document.swift
//  DirectoryViewer
//
//  Created by Shota HAMADA on 2018/02/11.
//  Copyright © 2018年 Shota HAMADA. All rights reserved.
//

import Cocoa

class Document: NSDocument {

    var directoryEntries = [DirectoryEntry]()

    override func read(from url: URL, ofType typeName: String) throws {
        directoryEntries.append(DirectoryEntry(url: url))
    }

    override func makeWindowControllers() {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Window Controller")) as! NSWindowController
        addWindowController(windowController)
        guard let mainViewController = windowController.contentViewController as? ViewController else { return }
        mainViewController.representedObject = directoryEntries
    }

}
