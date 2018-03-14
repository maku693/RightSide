//
//  DocumentController.swift
//  RightSide
//
//  Created by Shota HAMADA on 2018/02/11.
//  Copyright © 2018 Shota HAMADA. All rights reserved.
//

import Cocoa

class DocumentController: NSDocumentController {
    override func openDocument(_: Any?) {
        beginOpenPanel { [unowned self] URLs in
            guard let URLs = URLs else { return }

            if let document = self.currentDocument as? Document {
                self.read(URLs, into: document)
                return
            }

            let document = Document()
            self.read(URLs, into: document)
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

    func read(_ URLs: [URL], into document: Document) {
        for URL in URLs {
            do {
                let type = try typeForContents(of: URL)
                try document.read(from: URL, ofType: type)
                noteNewRecentDocumentURL(URL)
            } catch {
                presentError(error)
            }
        }
    }
}
