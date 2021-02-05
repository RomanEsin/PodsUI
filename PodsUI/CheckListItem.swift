//
//  CheckListItem.swift
//  PodsUI
//
//  Created by Роман Есин on 05.02.2021.
//

import SwiftUI

struct CheckListItem: View {

    @Binding var isChecked: Bool
    let text: String

    @State private var fadeOut = false

    var body: some View {
        Button(action: {
            fadeOut = true
            isChecked.toggle()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    fadeOut = false
                }
            }
        }, label: {
            HStack {
                Text(text)
                    .font(.title3)
                    .lineLimit(2)
                Spacer()
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isChecked ? .green : .secondary)
                    .font(.title.bold())
                    .scaleEffect(fadeOut ? 0.8 : 1)
                    .animation(.easeInOut)
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
        CheckListItem(isChecked: .constant(true), text: "Test")
            .previewLayout(.sizeThatFits)
    }
}
