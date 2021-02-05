//
//  ContentView.swift
//  PodsUI
//
//  Created by Роман Есин on 05.02.2021.
//

import SwiftUI
import AppKit

class Pod: ObservableObject {
    let name: String
    var isEnabled = true

    init(title: String) {
        self.name = title
    }
}

class PodModel: ObservableObject {
    @Published var pods: [Pod] = []
}

struct ContentView: View {

    @State var projectName = ""
    @State var pods: [Pod] = []
    @AppStorage("selectedURL") var selectedURL: URL?
    @State var podURL: URL?

    @State var isPresentingFileImporter = false
    @State var addPodIsShown = false
    @State var newPodText = ""
    @State var isLoading = true

    var body: some View {
        if selectedURL != nil && pods.isEmpty {
            DispatchQueue.main.async {
                loadPods()
                isLoading = false
            }
        } else {
            DispatchQueue.main.async {
                isLoading = false
            }
        }

        return ZStack {
            if selectedURL != nil {
                ScrollView {
                    ZStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Button(action: {
                                    selectedURL = nil
//                                    pods = []
                                }, label: {
                                    Image(systemName: "xmark")
                                        .frame(alignment: .trailing)
                                })

                                Spacer()
                                HStack {
                                    Text("Project:")
                                        .font(.largeTitle)
                                        .foregroundColor(.secondary)
                                    Text(projectName)
                                }
                                .font(.largeTitle.bold())
                                .frame(alignment: .center)
                                Spacer()

                                Button(action: {
                                    addPodIsShown = true
                                }, label: {
                                    Image(systemName: "plus")
                                        .frame(alignment: .trailing)
                                })
                            }
                            .padding(.horizontal)
                            .padding(.bottom)

                            ForEach(pods.indices, id: \.self) { index in
                                CheckListItem(isChecked: $pods[index].isEnabled, text: pods[index].name)
                                    .foregroundColor(pods[index].isEnabled ? Color(NSColor.textColor) : .secondary)
                                    .onChange(of: pods[index].isEnabled, perform: { value in
                                        setPodDisabled(pods[index], disabled: !value)
                                    })
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
                    isPresentingFileImporter = true
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
                .opacity(isLoading ? 0 : 1)
                .animation(.easeInOut)
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 500, minHeight: 700)
        .frame(maxWidth: 900, maxHeight: 1000)
        .sheet(isPresented: $addPodIsShown, content: {
            VStack {
                Spacer()
                TextField("New Pod name", text: $newPodText) { editingChanged in

                } onCommit: {
                    addPodIsShown = false
                }
                .font(.title)

                Spacer()
                Button(action: {
                    addPodIsShown = false
                }, label: {
                    Text("Cancel")
                })
            }
            .frame(width: 200, height: 200, alignment: .center)
            .padding()
        })
        .fileImporter(isPresented: $isPresentingFileImporter, allowedContentTypes: [.folder]) { result in
            switch result {
            case .success(let result):
                selectedURL = result
                loadPods()
            case .failure(let error):
                print(error)
            }
        }
    }

    func setPodDisabled(_ pod: Pod, disabled: Bool = true) {
        guard let podURL = self.podURL,
              let fileString = try? String(contentsOf: podURL) else { return }

        var lines = fileString.split(separator: "\n")

        for index in lines.indices {
            var splitLine = lines[index].split(separator: " ")
            if splitLine.contains("pod") && splitLine.count >= 2 {
                guard let _ = splitLine.first(where: { $0.contains(pod.name) }) else { continue }
                if disabled {
                    splitLine.insert("# ", at: 0)
                } else {
                    if splitLine.first == "#" {
                        splitLine.removeFirst()
                        splitLine.insert(" ", at: 0)
                    }
                }
                let newStr: String = splitLine.joined(separator: " ")
                print(newStr)
                lines[index] = String.SubSequence(newStr)
            }
        }
        let fullFile: String = lines.joined(separator: "\n")
        do {
            try fullFile.write(to: podURL, atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }
    }

    func loadPods() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: selectedURL!, includingPropertiesForKeys: nil)
            projectName = selectedURL!.lastPathComponent

            if let podfileURL = fileURLs.first(where: {
                $0.deletingPathExtension().lastPathComponent == "Podfile"
            }) {
                self.podURL = podfileURL
                let data = FileManager.default.contents(atPath: podfileURL.path)!
                let lines = String(data: data, encoding: .utf8)!.split(separator: "\n")
                for line in lines {
                    let splitLine = line.split(separator: " ")
                    if splitLine.contains("pod"), let podIndex = splitLine.firstIndex(of: "pod") {
                        var podName = splitLine[podIndex + 1]
                        podName.removeAll { $0 == "'" || $0 == "\"" || $0 == "," }
                        let pod = Pod(title: String(podName))
                        if splitLine.first == "#" {
                            pod.isEnabled = false
                        }
                        pods.append(pod)
                    }
                    pods.sort(by: { $0.name < $1.name} )
                }
            }
        } catch {
            print("Error while enumerating files \(selectedURL?.path ?? ""): \(error.localizedDescription)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(pods: [], isPresentingFileImporter: true)
    }
}
