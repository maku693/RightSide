//
//  UserDefaults.swift
//  RightSide
//
//  Created by Shota HAMADA on 2018/03/14.
//  Copyright © 2018 Shota HAMADA. All rights reserved.
//

import Foundation

extension UserDefaults {
    private static let showHiddenItemsKey = "ShowHiddenItems"
    private static let ignoredNamesKey = "IgnoredNames"

    var showHiddenItems: Bool {
        get { return bool(forKey: UserDefaults.showHiddenItemsKey) }
        set { set(newValue, forKey: UserDefaults.showHiddenItemsKey) }
    }
    var ignoredNames: [String] {
        get { return stringArray(forKey: UserDefaults.ignoredNamesKey) ?? [] }
        set { set(newValue, forKey: UserDefaults.ignoredNamesKey) }
    }

    func registerDefaults() {
        register(defaults: [
            UserDefaults.showHiddenItemsKey: true,
            UserDefaults.ignoredNamesKey: [".git", ".DS_Store"],
        ])
    }
}
