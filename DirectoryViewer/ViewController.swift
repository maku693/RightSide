//
//  ViewController.swift
//  DirectoryViewer
//
//  Created by Shota HAMADA on 2018/02/09.
//  Copyright © 2018年 Shota HAMADA. All rights reserved.
//

import Cocoa
import Quartz

class ViewController: NSViewController {

    @IBOutlet weak var outlineView: NSOutlineView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func acceptsPreviewPanelControl(_ panel: QLPreviewPanel!) -> Bool {
        return true
    }

    override func beginPreviewPanelControl(_ panel: QLPreviewPanel!) {
        panel.delegate = self
        panel.dataSource = representedObject as! Document
    }

    override func endPreviewPanelControl(_ panel: QLPreviewPanel!) {
        // Do Nothing
    }

    override func keyDown(with event: NSEvent) {
        guard event.charactersIgnoringModifiers == " " else { return }
        let appDelegate = NSApp.delegate as! AppDelegate
        appDelegate.togglePreviewPanel()
    }

}

extension ViewController: QLPreviewPanelDelegate {

    func previewPanel(_ panel: QLPreviewPanel!, handle event: NSEvent!) -> Bool {
        guard event.type == .keyDown else { return false }
        keyDown(with: event)
        return true
    }

    func previewPanel(_ panel: QLPreviewPanel!, sourceFrameOnScreenFor item: QLPreviewItem!) -> NSRect {
        let cell = outlineView.view(atColumn: outlineView.selectedColumn, row: outlineView.selectedRow, makeIfNecessary: true) as! NSTableCellView
        let rectOnWindow = cell.convert(cell.imageView!.frame, to: nil)
        return cell.window!.convertToScreen(rectOnWindow)
    }

    func previewPanel(_ panel: QLPreviewPanel!, transitionImageFor item: QLPreviewItem!, contentRect: UnsafeMutablePointer<NSRect>!) -> Any! {
        return (item as! DirectoryEntry).image
    }

}
