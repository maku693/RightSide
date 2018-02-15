//
//  DirectoryEntry.swift
//  DirectoryViewer
//
//  Created by Shota HAMADA on 2018/02/10.
//  Copyright © 2018年 Shota HAMADA. All rights reserved.
//

import Cocoa
import Quartz

class DirectoryEntry: NSObject {

    var url: URL
    @objc dynamic var title: String
    @objc dynamic var image: NSImage
    @objc dynamic var isFile: Bool
    @objc dynamic lazy var children: [DirectoryEntry] = isFile ? [] : DirectoryEntry.entriesFor(url)

    var delegate: DirectoryEntryDelegate?

    init(url: URL) {
        self.url = url.absoluteURL
        self.title = url.lastPathComponent
        self.image = NSWorkspace.shared.icon(forFile: url.path)
        self.isFile = true

        if let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey, .isPackageKey]),
            let isDirectory = resourceValues.isDirectory,
            let isPackage = resourceValues.isPackage {
            self.isFile = !isDirectory || isPackage
        }

        super.init()

        NSFileCoordinator.addFilePresenter(self)
    }

    deinit {
        NSFileCoordinator.removeFilePresenter(self)
    }
    
    func entryAtIndexPath(_ indexPath: IndexPath) -> DirectoryEntry {
        if indexPath.isEmpty {
            return self
        }
        let child = children[indexPath.first!]
        return child.entryAtIndexPath(indexPath.dropFirst())
    }

    static func entriesFor(_ url: URL) -> [DirectoryEntry] {
        guard let entryURLs = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey, .isPackageKey],
            options: [.skipsHiddenFiles]) else { return [] }

        return entryURLs
            .sorted {
                if let a: String = $0.absoluteString.removingPercentEncoding, let b = $1.absoluteString.removingPercentEncoding {
                    return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
                } else {
                    return true
                }
            }
            .map { DirectoryEntry(url: $0) }
    }

}

extension DirectoryEntry: NSFilePresenter {

    var presentedItemURL: URL? { return url }
    var presentedItemOperationQueue: OperationQueue { return .main }

    func presentedItemDidChange() {
        if isFile { return }
        children = DirectoryEntry.entriesFor(url)
    }

    func accommodatePresentedItemDeletion(completionHandler: @escaping (Error?) -> Void) {
        delegate?.directoryEntryWillDelete(self)
        completionHandler(nil)
    }

}

extension DirectoryEntry: QLPreviewItem {

    var previewItemURL: URL! { return url }
    var previewItemTitle: String { return title }

}

protocol DirectoryEntryDelegate {
    func directoryEntryWillDelete(_ directoryEntry: DirectoryEntry)
}

