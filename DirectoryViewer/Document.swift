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

    @objc dynamic var directoryEntries = [DirectoryEntry]()

    override func defaultDraftName() -> String {
        return NSLocalizedString("No item", comment: "")
    }

    override var displayName: String! {
        didSet {
            for windowController in windowControllers {
                windowController.synchronizeWindowTitleWithDocumentName()
            }
        }
    }

    override func read(from url: URL, ofType typeName: String) throws {
        let isURLAlreadyLoaded = directoryEntries.map { $0.url.absoluteString }.contains(url.absoluteString)
        if isURLAlreadyLoaded { return }
        let directoryEntry = DirectoryEntry(url: url)
        directoryEntry.delegate = self
        directoryEntries.append(directoryEntry)
        directoryEntries.sort { $0.url < $1.url }

        // Update title
        if directoryEntries.count == 1 {
            displayName = directoryEntries.first!.title
        } else {
            displayName = String(format: NSLocalizedString("%d items", comment: ""), directoryEntries.count)
        }
    }

    override func makeWindowControllers() {
        guard self.windowControllers.isEmpty else { return }

        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Window Controller")) as! NSWindowController
        addWindowController(windowController)
        windowController.contentViewController?.representedObject = self
    }

    func entriesForIndexPaths(_ indexPaths: [IndexPath]) -> [DirectoryEntry] {
        return indexPaths.map { indexPath in
            let currentIndex = indexPath.first!
            return directoryEntries[currentIndex].entryAtIndexPath(indexPath.dropFirst())
        }
    }

    func showEntriesForIndexPathsInFinder(_ indexPaths: [IndexPath]) {
        let urls = entriesForIndexPaths(indexPaths).map { $0.url }
        NSWorkspace.shared.activateFileViewerSelecting(urls)
    }

    func openEntriesForIndexPathsWithExternalEditor(_ indexPaths: [IndexPath]) {
        for entry in entriesForIndexPaths(indexPaths) {
            NSWorkspace.shared.openFile(entry.url.absoluteString)
        }
    }

    func removeRootEntriesForIndexSet(_ indexSet: IndexSet) {
        // IndexSet should be visited backwards to correctly remove items in an array
        for i in indexSet.reversed() {
            directoryEntries.remove(at: i)
        }
        displayName = defaultDraftName()
    }

}

extension Document: DirectoryEntryDelegate {

    func directoryEntryWillDelete(_ directoryEntry: DirectoryEntry) {
        guard let i = directoryEntries.index(of: directoryEntry) else { return }
        removeRootEntriesForIndexSet([i])
    }

}
