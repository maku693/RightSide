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
    @objc dynamic var selectionIndexPaths = [IndexPath]()

    @objc dynamic var activeIndexPaths: [IndexPath] {
        if !isViewLoaded || outlineView.selectedRowIndexes.contains(outlineView.clickedRow) {
            return selectionIndexPaths
        }
        guard let item = outlineView.item(atRow: outlineView.clickedRow) as? NSTreeNode else {
            return selectionIndexPaths
        }
        return [item.indexPath]
    }

    @objc dynamic var shouldEnableRemoveReference: Bool {
        return activeIndexPaths.reduce(true) { $0 && $1.count == 1 }
    }

    var document: Document? { return representedObject as? Document }

    override func viewDidLoad() {
        super.viewDidLoad()
        outlineView.setDraggingSourceOperationMask(.link, forLocal: false)
    }

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 49: // Space
            togglePreviewPanel()
        case 123, 124, 125, 126: // Left, Right, Up, Down
            outlineView.keyDown(with: event)
            QLPreviewPanel.shared().reloadData()
        default:
            nextResponder?.keyDown(with: event)
        }
    }

    @IBAction func showActiveEntriesInFinder(_ sender: Any) {
        document?.showEntriesForIndexPathsInFinder(activeIndexPaths)
    }

    @IBAction func openActiveEntriesWithExternalEditor(_ sender: Any) {
        document?.openEntriesForIndexPathsWithExternalEditor(activeIndexPaths)
    }

    @IBAction func removeActiveEntriesFromDocument(_ sender: Any) {
        let rootIndices = activeIndexPaths.flatMap { $0[0] }
        document?.removeRootEntriesForIndexSet(IndexSet(rootIndices))
    }

    func togglePreviewPanel() {
        if QLPreviewPanel.sharedPreviewPanelExists() && QLPreviewPanel.shared().isVisible {
            QLPreviewPanel.shared().orderOut(nil)
        } else if !selectionIndexPaths.isEmpty {
            QLPreviewPanel.shared().makeKeyAndOrderFront(nil)
        }
    }

    override func acceptsPreviewPanelControl(_ panel: QLPreviewPanel!) -> Bool {
        return true
    }

    override func beginPreviewPanelControl(_ panel: QLPreviewPanel!) {
        panel.delegate = self
        panel.dataSource = self
    }

    override func endPreviewPanelControl(_ panel: QLPreviewPanel!) {
        // Do Nothing
    }

}

extension ViewController: NSOutlineViewDataSource {

    func outlineView(_ outlineView: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard) -> Bool {
        guard let nodes = items as? [NSTreeNode] else { return false }
        let urls = nodes
            .map { $0.representedObject as? DirectoryEntry }
            .flatMap { $0?.url } // Exclude `nil`
            .map { $0 as NSURL }
        pasteboard.writeObjects(urls)
        return true
    }

}

extension ViewController: QLPreviewPanelDataSource {

    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        return activeIndexPaths.count
    }

    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        return document?.entriesForIndexPaths(activeIndexPaths)[index]
    }

}

extension ViewController: QLPreviewPanelDelegate {

    func previewPanel(_ panel: QLPreviewPanel!, handle event: NSEvent!) -> Bool {
        if event.type != .keyDown { return false }
        keyDown(with: event)
        return true
    }

    func previewPanel(_ panel: QLPreviewPanel!, sourceFrameOnScreenFor item: QLPreviewItem!) -> NSRect {
        guard let cell = outlineView.view(atColumn: outlineView.selectedColumn, row: outlineView.selectedRow, makeIfNecessary: true) as? NSTableCellView else { return .zero }
        let rectOnWindow = cell.convert(cell.imageView?.frame ?? .zero, to: nil)
        return cell.window!.convertToScreen(rectOnWindow)
    }

    func previewPanel(_ panel: QLPreviewPanel!, transitionImageFor item: QLPreviewItem!, contentRect: UnsafeMutablePointer<NSRect>!) -> Any! {
        guard let entry = item as? DirectoryEntry else { return nil }
        return entry.image
    }

}
