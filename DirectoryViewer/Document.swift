//
//  Document.swift
//  DirectoryViewer
//
//  Created by Shota HAMADA on 2018/02/11.
//  Copyright © 2018年 Shota HAMADA. All rights reserved.
//

import Cocoa

class Document: NSDocument {

    @objc dynamic var directoryEntries = [DirectoryEntry]()

    override func read(from url: URL, ofType typeName: String) throws {
        let directoryEntry = DirectoryEntry(url: url)
        directoryEntry.delegate = self
        directoryEntries.append(directoryEntry)
    }

    override func makeWindowControllers() {
        guard self.windowControllers.isEmpty else { return }

        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Window Controller")) as! NSWindowController
        addWindowController(windowController)
        windowController.contentViewController?.representedObject = windowController.document
    }

}

extension Document: DirectoryEntryDelegate {

    func directoryEntryWillDelete(_ directoryEntry: DirectoryEntry) {
        if let i = directoryEntries.index(of: directoryEntry) {
            directoryEntries.remove(at: i)
        }
        if directoryEntries.isEmpty {
            close()
        }
    }

}
