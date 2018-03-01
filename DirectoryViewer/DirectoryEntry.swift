//
//  DirectoryEntry.swift
//  DirectoryViewer
//
//  Created by Shota HAMADA on 2018/02/10.
//  Copyright © 2018年 Shota HAMADA. All rights reserved.
//

import Cocoa
import Quartz

protocol DirectoryEntryDelegate : class {
    func directoryEntryDidDelete(_ directoryEntry: DirectoryEntry)
}

class DirectoryEntry: NSObject {

    var URL: URL
    @objc dynamic var isFile: Bool
    @objc dynamic lazy var title: String = FileManager.default.displayName(atPath: URL.path)
    @objc dynamic lazy var image: NSImage = loadIcon()
    @objc dynamic lazy var children: Set<DirectoryEntry> = loadChildren()

    weak var delegate: DirectoryEntryDelegate?

    override var hash: Int { return URL.path.hash }

    private var fileSystemMonitor: FileSystemMonitor

    init(URL: URL) {
        self.URL = URL.absoluteURL
        self.isFile = true
        self.fileSystemMonitor = FileSystemMonitor(monitoringURL: URL)

        if let resourceValues = try? URL.resourceValues(forKeys: [.isDirectoryKey, .isPackageKey]),
            let isDirectory = resourceValues.isDirectory,
            let isPackage = resourceValues.isPackage {
            self.isFile = !isDirectory || isPackage
        }

        super.init()

        fileSystemMonitor.delegate = self
        fileSystemMonitor.startMonitoring()
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? DirectoryEntry else { return false }
        return URL.path == other.URL.path
    }

    private func loadIcon() -> NSImage {
        let icon = NSWorkspace.shared.icon(forFile: URL.path)
        icon.size = NSSize(width: 16, height: 16)
        return icon
    }

    private func loadChildren() -> Set<DirectoryEntry> {
        if isFile { return [] }
        guard let URLs = try? FileManager.default.contentsOfDirectory(at: URL, includingPropertiesForKeys: [.isDirectoryKey, .isPackageKey], options: [.skipsHiddenFiles]) else { return [] }
        let entries = URLs.map { DirectoryEntry(URL: $0) }
        return Set(entries)
    }

}

extension DirectoryEntry: QLPreviewItem {

    var previewItemURL: URL! { return URL }
    var previewItemTitle: String { return title }

}

extension DirectoryEntry: FileSystemMonitorDelegate {

    func fileSystemMonitorDidObserveChange(_ fileSystemMonitor: FileSystemMonitor) {
        if isFile { return }
        let newChildren = loadChildren()
        if children == newChildren { return }
        let removed = children.subtracting(newChildren)
        let added = newChildren.subtracting(children)
        DispatchQueue.main.sync {
            if !removed.isEmpty {
                children.subtract(removed)
            }
            if !added.isEmpty {
                children.formUnion(added)
            }
        }
    }

    func fileSystemMonitorDidObserveDelete(_ fileSystemMonitor: FileSystemMonitor) {
        delegate?.directoryEntryDidDelete(self)
    }

}
