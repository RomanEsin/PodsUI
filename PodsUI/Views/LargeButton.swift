//
//  LargeButton.swift
//  PodsUI
//
//  Created by Роман Есин on 10.02.2021.
//

import SwiftUI

struct LargeButton: View {
    let title: String
    let systemName: String

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title)
                .foregroundColor(.secondary)
            Image(systemName: systemName)
                .font(.system(size: 38))
                .foregroundColor(.blue)
        }
        .padding(16)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(16)
    }
}

struct LargeButton_Previews: PreviewProvider {
    static var previews: some View {
        LargeButton(title: "Test", systemName: "circle")
    }
}
