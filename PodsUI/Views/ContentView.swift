//
//  ContentView.swift
//  PodsUI
//
//  Created by Роман Есин on 05.02.2021.
//

import SwiftUI
import AppKit

struct ContentView: View {

    @StateObject var podProject = Project.shared

    @State var isPresentingFileImporter = false
    @State var addPodIsShown = false
    @State var newPodText = ""
    @State var newPodVersion = ""

    var body: some View {
        if podProject.selectedURL != nil && podProject.pods.isEmpty {
            DispatchQueue.main.async {
                guard podProject.selectedURL != nil else { return }
                podProject.loadPods(podProject.selectedURL!)
                podProject.isLoading = false
            }
        } else {
            DispatchQueue.main.async {
                podProject.isLoading = false
            }
        }

        return ZStack {
            if podProject.selectedURL != nil {
                if podProject.hasPodfile {
                    // MARK: With Podfile
                    ScrollView {
                        ZStack {
                            VStack(alignment: .leading) {
                                HStack(alignment: .center) {
                                    Button(action: {
                                        podProject.selectedURL = nil
                                    }, label: {
                                        Text("Close")
                                            .frame(alignment: .trailing)
                                    })

                                    Spacer()
                                    HStack {
                                        Text("Project:")
                                            .font(.largeTitle)
                                            .foregroundColor(.secondary)
                                        Text(podProject.projectName)
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

                                ForEach(podProject.pods.indices, id: \.self) { index in
                                    CheckListItem(pod: .init(get: { podProject.pods[index] },
                                                             set: { podProject.pods[index] = $0 }))
                                        .foregroundColor(podProject.pods[index].isEnabled ? Color(NSColor.textColor) : .secondary)
                                        .onChange(of: podProject.pods[index].isEnabled, perform: { value in
                                            setPodDisabled(podProject.pods[index], disabled: !value)
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
                    .transition(.opacity.animation(.easeInOut(duration: 0.25)))

                    if podProject.pods.isEmpty {
                        VStack {
                            Text("No Pods are in the project right now.")
                                .font(.title2)
                                .foregroundColor(.secondary)

                            Button {
                                addPodIsShown = true
                            } label: {
                                LargeButton(title: "Add Pod",
                                            systemName: "plus.circle.fill")
                            }
                            .animation(.easeInOut(duration: 0.25))
                            .buttonStyle(PlainButtonStyle())
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    // MARK: No Podfile
                    ZStack {
                        VStack {
                            HStack {
                                Button(action: {
                                    podProject.selectedURL = nil
                                }, label: {
                                    Text("Close")
                                        .frame(alignment: .trailing)
                                })
                                Spacer()
                            }
                            .padding()

                            Text("No Podfile detected in the project")
                                .font(.largeTitle.bold())
                                .multilineTextAlignment(.center)
                                .padding()
                            Spacer()
                        }

                        Button(action: {
                            let bash = Bash()
                            
                            if let log = try? bash.run(commandName: "bash",
                                                     arguments: ["-c", "cd \(podProject.selectedURL!.path); /usr/local/bin/pod init;"]) {
                                print(log)
                                podProject.loadPods(podProject.selectedURL!)
                            }

                        }, label: {
                            LargeButton(title: "Generate a Podfile",
                                        systemName: "plus.circle.fill")
                        })
                        .opacity(podProject.isLoading ? 0 : 1)
                        .animation(.easeInOut(duration: 0.25))
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity.animation(.easeInOut(duration: 0.25)))
                }
            } else {
                // MARK: Intro
                Button(action: {
                    isPresentingFileImporter = true
                }, label: {
                    LargeButton(title: "Select project folder",
                                systemName: "folder.badge.plus")
                })
                .opacity(podProject.isLoading ? 0 : 1)
                .animation(.easeInOut(duration: 0.25))
                .buttonStyle(PlainButtonStyle())
                .transition(.opacity.animation(.easeInOut(duration: 0.25)))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 420, minHeight: 600)
        .frame(maxWidth: 800, maxHeight: .infinity)
        .sheet(isPresented: $addPodIsShown, content: {
            Form {
                VStack(alignment: .center) {
                    Text("Add new Pod")
                        .font(.title2)

                    TextField("New Pod name", text: $newPodText) { editingChanged in

                    } onCommit: {

                    }
                    .font(.title2)

                    TextField("Pod version", text: $newPodVersion) { editingChanged in

                    } onCommit: {
                        addPodIsShown = false
                    }
                    .font(.title2)

                    Spacer()

                    HStack {
                        Button(action: {
                            addPodIsShown = false
                        }, label: {
                            Text("Cancel")
                        })

                        Button(action: {
                            addPodIsShown = false
                        }, label: {
                            Text("Add Pod")
                        })
                        .disabled(newPodText.count == 0)
                    }
                }
            }
            .frame(width: 200, height: 200, alignment: .center)
            .padding()
        })
        .fileImporter(isPresented: $isPresentingFileImporter, allowedContentTypes: [.folder]) { result in
            switch result {
            case .success(let result):
                podProject.loadPods(result)
            case .failure(let error):
                print(error)
            }
        }
    }

    func setPodDisabled(_ pod: Pod, disabled: Bool = true) {
        guard let podURL = self.podProject.podURL,
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
