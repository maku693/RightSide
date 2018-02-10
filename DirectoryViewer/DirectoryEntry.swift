//
//  DirectoryEntry.swift
//  DirectoryViewer
//
//  Created by Shota HAMADA on 2018/02/10.
//  Copyright © 2018年 Shota HAMADA. All rights reserved.
//

import Cocoa

class DirectoryEntry: NSObject {

    @objc dynamic var title: String?
    @objc dynamic var image: NSImage?
    @objc dynamic var children: [DirectoryEntry]

    init(title: String?, image: NSImage?, children: [DirectoryEntry]) {
        self.title = title
        self.image = image
        self.children = children
        super.init()
    }

}

