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
    @objc dynamic var children: [DirectoryEntry] = []

    init(url: URL) {
        self.url = url.absoluteURL
        self.title = url.lastPathComponent
        self.image = NSWorkspace.shared.icon(forFile: url.path)
        self.children = DirectoryEntry.entries(for: url)

        super.init()
    }

}

extension DirectoryEntry {

    static func entries(for url: URL) -> [DirectoryEntry] {
        guard let entriesPath = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil) else { return [] }

        return entriesPath.map { DirectoryEntry(url: $0) }
    }

}

