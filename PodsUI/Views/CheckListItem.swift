//
//  CheckListItem.swift
//  PodsUI
//
//  Created by Роман Есин on 05.02.2021.
//

import SwiftUI

struct CheckListItem: View {

    @Binding var pod: Pod

    @State private var fadeOut = false

    var body: some View {
        Button(action: {
            fadeOut = true
            pod.isEnabled.toggle()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    fadeOut = false
                }
            }
        }, label: {
            HStack {
                Text(pod.name)
                    .font(.title3)
                    .lineLimit(2)
                Text(pod.version)
                    .font(.title3)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: pod.isEnabled ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(pod.isEnabled ? .green : .secondary)
                    .font(.title.bold())
                    .scaleEffect(fadeOut ? 0.8 : 1)
                    .animation(.easeInOut(duration: 0.2))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.textBackgroundColor))
            .padding(.horizontal)
        })
        .buttonStyle(PlainButtonStyle())
    }
}

struct CheckListItem_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
//        CheckListItem(isChecked: .constant(true), text: "Test", version: "~> 1.0.0")
//            .previewLayout(.sizeThatFits)
    }
}
