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

    // MARK: Properties

    @IBOutlet var treeController: NSTreeController!
    @IBOutlet var outlineView: NSOutlineView!

    var activeNodes: [NSTreeNode] {
        if !isViewLoaded {
            return []
        }
        if outlineView.selectedRowIndexes.contains(outlineView.clickedRow) {
            return treeController.selectedNodes
        }
        guard let clickedNode = outlineView.item(atRow: outlineView.clickedRow) as? NSTreeNode else {
            return treeController.selectedNodes
        }
        return [clickedNode]
    }

    var activeIndexPaths: [IndexPath] {
        return activeNodes.map { $0.indexPath }
    }

    var activeObjects: [Any] {
        return activeNodes.map { $0.representedObject }.flatMap { $0 }
    }

    @objc dynamic var isSelectingRootNodesOnly: Bool {
        return activeNodes.reduce(true) { $0 && $1.parent?.parent == nil }
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        let sortDescriptor = NSSortDescriptor(key: "title",
                                              ascending: true,
                                              selector: #selector(NSString.localizedStandardCompare(_:)))
        treeController.sortDescriptors.append(sortDescriptor)
        outlineView.setDraggingSourceOperationMask(.link, forLocal: false)
    }

    // MARK: Actions

    @IBAction func showActiveEntriesInFinder(_: Any) {
        guard let activeEntries = activeObjects as? [DirectoryEntry] else { return }
        let urls = activeEntries.map { $0.URL }
        NSWorkspace.shared.activateFileViewerSelecting(urls)
    }

    @IBAction func openActiveEntriesWithExternalEditor(_: Any) {
        for object in activeObjects {
            guard let entry = object as? DirectoryEntry else { continue }
            NSWorkspace.shared.openFile(entry.URL.path)
        }
    }

    @IBAction func removeActiveEntriesFromDocument(_: Any) {
        treeController.removeObjects(atArrangedObjectIndexPaths: activeIndexPaths)
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

    private func togglePreviewPanel() {
        if QLPreviewPanel.sharedPreviewPanelExists() && QLPreviewPanel.shared().isVisible {
            QLPreviewPanel.shared().orderOut(nil)
        } else if !treeController.selectionIndexPaths.isEmpty {
            QLPreviewPanel.shared().makeKeyAndOrderFront(nil)
        }
    }

    // MARK: QuickLook

    override func acceptsPreviewPanelControl(_: QLPreviewPanel!) -> Bool {
        return true
    }

    override func beginPreviewPanelControl(_ panel: QLPreviewPanel!) {
        panel.delegate = self
        panel.dataSource = self
    }

    override func endPreviewPanelControl(_: QLPreviewPanel!) {
        // Do Nothing
    }
}

extension ViewController: NSOutlineViewDataSource {
    func outlineView(_: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard) -> Bool {
        guard let nodes = items as? [NSTreeNode] else { return false }
        let urls = nodes
            .map { node -> NSURL? in
                let entry = node.representedObject as? DirectoryEntry
                let url = entry?.URL as NSURL?
                return url
            }
            .flatMap { $0 }
        pasteboard.writeObjects(urls)
        return true
    }
}

extension ViewController: QLPreviewPanelDataSource {
    func numberOfPreviewItems(in _: QLPreviewPanel!) -> Int {
        return activeIndexPaths.count
    }

    func previewPanel(_: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        return activeObjects[index] as? DirectoryEntry
    }
}

extension ViewController: QLPreviewPanelDelegate {
    func previewPanel(_: QLPreviewPanel!, handle event: NSEvent!) -> Bool {
        if event.type != .keyDown { return false }
        keyDown(with: event)
        return true
    }

    func previewPanel(_: QLPreviewPanel!, sourceFrameOnScreenFor _: QLPreviewItem!) -> NSRect {
        guard let cell = outlineView.view(atColumn: outlineView.selectedColumn,
                                          row: outlineView.selectedRow,
                                          makeIfNecessary: false) as? NSTableCellView
        else { return .zero }
        let cellRectOnWindow = cell.convert(cell.imageView?.frame ?? .zero, to: nil)
        if !view.frame.contains(cellRectOnWindow) { return .zero }
        return cell.window!.convertToScreen(cellRectOnWindow)
    }

    func previewPanel(_: QLPreviewPanel!,
                      transitionImageFor item: QLPreviewItem!,
                      contentRect _: UnsafeMutablePointer<NSRect>!) -> Any! {
        guard let entry = item as? DirectoryEntry else { return nil }
        return entry.image
    }
}
