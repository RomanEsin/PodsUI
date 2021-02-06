//
//  Pod.swift
//  PodsUI
//
//  Created by Роман Есин on 06.02.2021.
//

import SwiftUI

struct Pod {
    let name: String
    var version: String
    var isEnabled = true

    init(title: String, version: String) {
        self.name = title
        self.version = version
    }
}
