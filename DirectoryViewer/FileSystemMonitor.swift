//
//  DirectoryWatcher.swift
//  DirectoryViewer
//
//  Created by Shota HAMADA on 2018/02/22.
//  Copyright © 2018年 Shota HAMADA. All rights reserved.
//

import Cocoa

protocol FileSystemMonitorDelegate : class {

    func fileSystemMonitorDidObserveChange(_ fileSystemMonitor: FileSystemMonitor)
    func fileSystemMonitorDidObserveDelete(_ fileSystemMonitor: FileSystemMonitor)

}

class FileSystemMonitor {

    var monitoringURL: URL
    weak var delegate: FileSystemMonitorDelegate?

    private var dispatchSource: DispatchSourceFileSystemObject?
    private var fileDescriptor: Int32

    init(monitoringURL: URL) {
        self.monitoringURL = monitoringURL

        fileDescriptor = -1
        fileDescriptor = open(monitoringURL.path, O_EVTONLY)
        guard fileDescriptor != -1 else { return }

        dispatchSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: [.write, .delete])
        dispatchSource?.setEventHandler { [weak self] in
            guard let strongSelf = self,
                let event = strongSelf.dispatchSource?.data else { return }

            switch event {
            case .write:
                strongSelf.delegate?.fileSystemMonitorDidObserveChange(strongSelf)
            case .delete:
                strongSelf.delegate?.fileSystemMonitorDidObserveDelete(strongSelf)
            default:
                break
            }
        }
    }

    deinit {
        dispatchSource?.cancel()
        close(fileDescriptor)
    }

    func startMonitoring() {
        dispatchSource?.resume()
    }

    func endMonitoring() {
        dispatchSource?.suspend()
    }
}

extension FileSystemMonitor: Equatable {

    static func ==(lhs: FileSystemMonitor, rhs: FileSystemMonitor) -> Bool {
        return lhs.monitoringURL.path == rhs.monitoringURL.path
    }

}
