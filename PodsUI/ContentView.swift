//
//  ContentView.swift
//  PodsUI
//
//  Created by Роман Есин on 05.02.2021.
//

import SwiftUI
import AppKit

class Pod: ObservableObject {
    let title: String
    var isChecked = true

    init(title: String) {
        self.title = title
    }
}

class PodModel: ObservableObject {
    @Published var pods: [Pod] = []
}

struct ContentView: View {

    @State var pods: [Pod] = []
    @State var isDropEntered = false
    @State var selectedURL = URL(string: "file://Users/romanesin/Desktop/")!

    var body: some View {
        ZStack {
            if pods.count > 0 {
                ScrollView {
                    ZStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Button(action: {}, label: {
                                    Image(systemName: "plus")
                                        .frame(alignment: .trailing)
                                })
                                .opacity(0)

                                Spacer()
                                Text("Project name")
                                    .font(.largeTitle.bold())
                                    .frame(alignment: .center)
                                Spacer()

                                Button(action: {

                                }, label: {
                                    Image(systemName: "plus")
                                        .frame(alignment: .trailing)
                                })
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                            ForEach(pods.indices, id: \.self) { index in
                                HStack {
                                    CheckListItem(isChecked: $pods[index].isChecked, text: pods[index].title)
                                        .foregroundColor(pods[index].isChecked ? Color(NSColor.textColor) : .secondary)
                                }
                                .frame(maxWidth: .infinity)
                                Divider()
                            }
                        }
                        .padding(.vertical)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .background(Color(NSColor.textBackgroundColor))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Button(action: {
                    isDropEntered = true
                }, label: {
                    VStack(spacing: 16) {
                        Text("Select project folder")
                            .font(.title)
                            .foregroundColor(.secondary)
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 38))
                            .foregroundColor(Color(NSColor.textColor))
                    }
                    .padding(16)
                    .background(Color(NSColor.windowBackgroundColor).cornerRadius(16))
                })
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 500, minHeight: 700)
        .frame(maxWidth: 900, maxHeight: 1000)
        .fileImporter(isPresented: $isDropEntered, allowedContentTypes: [.folder]) { result in
            switch result {
            case .success(let result):
                selectedURL = result

                let fileManager = FileManager.default

                do {
                    let fileURLs = try fileManager.contentsOfDirectory(at: selectedURL, includingPropertiesForKeys: nil)
                    if let podfileURL = fileURLs.first(where: { $0.deletingPathExtension().lastPathComponent == "Podfile" }) {
                        let data = fileManager.contents(atPath: podfileURL.path)!
                        let lines = String(data: data, encoding: .utf8)!.split(separator: "\n")
                        for line in lines {
                            let split = line.split(separator: " ")
                            if split.contains("pod") && split.count >= 2 {
                                var str = split[1]
                                str.removeAll(where: { $0 == "'" || $0 == "\"" || $0 == "," })
                                pods.append(Pod(title: String(str)))
                            }
                            pods.sort(by: { $0.title < $1.title} )
                        }
                    }
                } catch {
                    print("Error while enumerating files \(selectedURL): \(error.localizedDescription)")
                }

            case .failure:
                break
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(pods: [], isDropEntered: true, selectedURL: URL(string: "https://youtube.com")!)
    }
}
