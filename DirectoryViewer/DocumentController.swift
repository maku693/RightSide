//
//  DocumentController.swift
//  DirectoryViewer
//
//  Created by Shota HAMADA on 2018/02/11.
//  Copyright © 2018年 Shota HAMADA. All rights reserved.
//

import Cocoa

class DocumentController: NSDocumentController {
    override func openDocument(_: Any?) {
        beginOpenPanel { [unowned self] urls in
            guard let urls = urls else { return }

            if let document = self.currentDocument as? Document {
                self.readURLs(urls, into: document)
                return
            }

            let document = Document()
            self.readURLs(urls, into: document)
            self.addDocument(document)
            document.makeWindowControllers()
            document.showWindows()
        }
    }

    override func beginOpenPanel(_ openPanel: NSOpenPanel,
                                 forTypes inTypes: [String]?,
                                 completionHandler: @escaping (Int) -> Void) {
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        super.beginOpenPanel(openPanel, forTypes: inTypes, completionHandler: completionHandler)
    }

    func readURLs(_ urls: [URL], into document: Document) {
        for url in urls {
            do {
                let type = try typeForContents(of: url)
                try document.read(from: url, ofType: type)
                noteNewRecentDocumentURL(url)
            } catch {
                presentError(error)
            }
        }
    }
}
