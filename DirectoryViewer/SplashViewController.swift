//
//  OpenViewController.swift
//  DirectoryViewer
//
//  Created by Shota HAMADA on 2018/02/11.
//  Copyright © 2018年 Shota HAMADA. All rights reserved.
//

import Cocoa

class SplashViewController: NSViewController {
    private let showDirectorySegue = NSStoryboardSegue.Identifier(rawValue: "showDirectory")
    private let openPanel: NSOpenPanel = {
        let value = NSOpenPanel()
        value.canChooseFiles = false
        value.canChooseDirectories = true
        return value
    }()

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard segue.identifier == showDirectorySegue else { return }
        let destinationController = segue.destinationController as! MainViewController
        let entries = openPanel.urls.map { DirectoryEntry(url: $0) }
        destinationController.directoryEntries = entries
    }

    @IBAction func showOpenPanel(_ sender: Any) {
        openPanel.begin { [unowned self] response in
            guard response == .OK else { return }
            self.performSegue(withIdentifier: self.showDirectorySegue, sender: self)
        }
    }

}
