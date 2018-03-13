//
//  DirectoryEntry.swift
//  RightSide
//
//  Created by Shota HAMADA on 2018/02/10.
//  Copyright © 2018 Shota HAMADA. All rights reserved.
//

import Cocoa
import Quartz

protocol DirectoryEntryDelegate: class {
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
        isFile = true
        fileSystemMonitor = FileSystemMonitor(monitoringURL: URL)

        if let resourceValues = try? URL.resourceValues(forKeys: [.isDirectoryKey, .isPackageKey]),
            let isDirectory = resourceValues.isDirectory,
            let isPackage = resourceValues.isPackage {
            isFile = !isDirectory || isPackage
        }

        super.init()

        fileSystemMonitor.delegate = self
        fileSystemMonitor.startMonitoring()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refresh),
                                               name: UserDefaults.didChangeNotification,
                                               object: nil)
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
        guard !isFile else { return [] }

        let contentsOptions: FileManager.DirectoryEnumerationOptions =
            UserDefaults.standard.showHiddenItems ? [] : [.skipsHiddenFiles]
        guard let URLs = try? FileManager.default.contentsOfDirectory(at: URL,
                                                                      includingPropertiesForKeys: [
                                                                          .isDirectoryKey, .isPackageKey, .isHiddenKey
                                                                      ],
                                                                      options: contentsOptions)
        else { return [] }

        let entries = URLs
            .filter { URL in
                guard UserDefaults.standard.showHiddenItems else { return true }
                guard let resourceValues = try? URL.resourceValues(forKeys: [.isHiddenKey]),
                    resourceValues.isHidden ?? false
                else { return true }
                return !UserDefaults.standard.ignoredNames.contains(URL.lastPathComponent)
            }
            .map { DirectoryEntry(URL: $0) }
        return Set(entries)
    }

    @objc private func refresh(_ sender: Any?) {
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else { return }

            guard !strongSelf.isFile else { return }

            let newChildren = strongSelf.loadChildren()
            guard strongSelf.children != newChildren else { return }

            let removed = strongSelf.children.subtracting(newChildren)
            let added = newChildren.subtracting(strongSelf.children)

            DispatchQueue.main.sync { [weak self] in
                guard let strongSelf = self else { return }
                if !removed.isEmpty {
                    strongSelf.children.subtract(removed)
                }
                if !added.isEmpty {
                    strongSelf.children.formUnion(added)
                }
            }
        }
    }
}

extension DirectoryEntry: QLPreviewItem {
    var previewItemURL: URL! { return URL }
    var previewItemTitle: String { return title }
}

extension DirectoryEntry: FileSystemMonitorDelegate {
    func fileSystemMonitorDidObserveChange(_: FileSystemMonitor) {
        refresh(self)
    }

    func fileSystemMonitorDidObserveDelete(_: FileSystemMonitor) {
        delegate?.directoryEntryDidDelete(self)
    }
}
