//
//  Document.swift
//  DirectoryViewer
//
//  Created by Shota HAMADA on 2018/02/11.
//  Copyright © 2018年 Shota HAMADA. All rights reserved.
//

import Cocoa
import Quartz

class Document: NSDocument {

    @objc dynamic var directoryEntries = Set<DirectoryEntry>() {
        didSet { updateDisplayName() }
    }

    var windowController: NSWindowController? { return windowControllers.first }

    override func defaultDraftName() -> String {
        return NSLocalizedString("No item", comment: "")
    }

    override func read(from URL: URL, ofType typeName: String) throws {
        let directoryEntry = DirectoryEntry(URL: URL)
        directoryEntries.insert(directoryEntry)
        updateDisplayName()
    }

    override func makeWindowControllers() {
        guard windowControllers.isEmpty else { return }

        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        guard let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Window Controller")) as? NSWindowController else { return }
        addWindowController(windowController)
        windowController.contentViewController?.representedObject = self
    }

    private func updateDisplayName() {
        switch directoryEntries.count {
        case 0:
            displayName = defaultDraftName()
        case 1:
            displayName = directoryEntries.first!.title
        default:
            displayName = String(format: NSLocalizedString("%d items", comment: ""), directoryEntries.count)
        }
        windowController?.synchronizeWindowTitleWithDocumentName()
    }

}
