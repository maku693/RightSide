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

    var URL: URL
    @objc dynamic var isFile: Bool
    @objc dynamic lazy var title: String = URL.lastPathComponent
    @objc dynamic lazy var image: NSImage = NSWorkspace.shared.icon(forFile: URL.path)
    @objc dynamic lazy var children: Set<DirectoryEntry> = {
        if isFile { return [] }
        guard let URLs = try? FileManager.default.contentsOfDirectory(at: URL, includingPropertiesForKeys: [.isDirectoryKey, .isPackageKey], options: [.skipsHiddenFiles]) else { return [] }
        let entries = URLs.map { DirectoryEntry(URL: $0) }
        return Set(entries)
    }()

    override var hash: Int { return URL.path.hash }

    init(URL: URL) {
        self.URL = URL.absoluteURL
        self.isFile = true

        if let resourceValues = try? URL.resourceValues(forKeys: [.isDirectoryKey, .isPackageKey]),
            let isDirectory = resourceValues.isDirectory,
            let isPackage = resourceValues.isPackage {
            self.isFile = !isDirectory || isPackage
        }

        super.init()
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? DirectoryEntry else { return false }
        return URL.path == other.URL.path
    }

}

extension DirectoryEntry: QLPreviewItem {

    var previewItemURL: URL! { return URL }
    var previewItemTitle: String { return title }

}

