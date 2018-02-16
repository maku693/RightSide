//
//  URL+Sort.swift
//  DirectoryViewer
//
//  Created by Shota HAMADA on 2018/02/17.
//  Copyright © 2018年 Shota HAMADA. All rights reserved.
//

import Foundation

extension URL: Comparable {

    public static func <(lhs: URL, rhs: URL) -> Bool {
        guard let lhs = lhs.absoluteString.removingPercentEncoding,
            let rhs = rhs.absoluteString.removingPercentEncoding else { return true }
        return lhs.localizedCaseInsensitiveCompare(rhs) == .orderedAscending
    }

}
