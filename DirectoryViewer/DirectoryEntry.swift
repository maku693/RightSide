//
//  DirectoryEntry.swift
//  DirectoryViewer
//
//  Created by Shota HAMADA on 2018/02/10.
//  Copyright © 2018年 Shota HAMADA. All rights reserved.
//

import Cocoa

class DirectoryEntry: NSObject {

    var url: URL
    @objc dynamic var title: String
    @objc dynamic var image: NSImage
    @objc dynamic var isFile: Bool
    @objc dynamic lazy var children: [DirectoryEntry] = isFile ? [] : DirectoryEntry.entries(for: url)

    init(url: URL) {
        self.url = url.absoluteURL
        self.title = url.lastPathComponent
        self.image = NSWorkspace.shared.icon(forFile: url.path)
        self.isFile = true

        if let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey, .isPackageKey]),
            resourceValues.isDirectory! && !resourceValues.isPackage! {
            self.isFile = false
        }

        super.init()
    }

}

extension DirectoryEntry {

    static func entries(for url: URL) -> [DirectoryEntry] {
        guard let entryURLs = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey, .isPackageKey],
            options: [.skipsHiddenFiles]) else { return [] }

        return entryURLs.map { DirectoryEntry(url: $0) }
    }

}

