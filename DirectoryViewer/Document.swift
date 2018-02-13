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
    @objc dynamic var selectionIndexPaths = [IndexPath]()

    override func read(from url: URL, ofType typeName: String) throws {
        let directoryEntry = DirectoryEntry(url: url)
        directoryEntry.delegate = self
        directoryEntries.append(directoryEntry)

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

extension Document: QLPreviewPanelDataSource {

    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        return selectionIndexPaths.count
    }

    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        let indexPath = selectionIndexPaths[index]
        let currentIndex = indexPath.first!
        return directoryEntries[currentIndex].entryAtIndexPath(indexPath.dropFirst())
    }

}
