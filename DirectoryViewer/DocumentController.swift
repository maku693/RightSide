//
//  DocumentController.swift
//  DirectoryViewer
//
//  Created by Shota HAMADA on 2018/02/11.
//  Copyright © 2018年 Shota HAMADA. All rights reserved.
//

import Cocoa

class DocumentController: NSDocumentController {

    override func openDocument(_ sender: Any?) {
        beginOpenPanel { [unowned self] urls in
            guard let urls = urls else { return }
            let document = Document()
            for url in urls {
                let type = try! self.typeForContents(of: url)
                try! document.read(from: url, ofType: type)
            }
            self.addDocument(document)
            document.makeWindowControllers()
            document.showWindows()
        }
    }

    override func beginOpenPanel(_ openPanel: NSOpenPanel, forTypes inTypes: [String]?, completionHandler: @escaping (Int) -> Void) {
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        super.beginOpenPanel(openPanel, forTypes: inTypes, completionHandler: completionHandler)
    }

}
