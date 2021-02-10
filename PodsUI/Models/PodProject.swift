//
//  PodProject.swift
//  PodsUI
//
//  Created by Роман Есин on 10.02.2021.
//

import SwiftUI

class Project: ObservableObject {
    @AppStorage("selectedURL") var selectedURL: URL? {
        didSet {
            podURL = nil
            hasPodfile = false
            projectName = ""
            isLoading = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.pods = []
            }
        }
    }

    @Published var pods: [Pod] = []
    @Published var podURL: URL?
    @Published var hasPodfile = false
    @Published var projectName = ""
    @Published var isLoading = true

    func loadPods(_ url: URL) {
        self.selectedURL = url
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: selectedURL!, includingPropertiesForKeys: nil)
            projectName = selectedURL!.lastPathComponent

            if let podfileURL = fileURLs.first(where: {
                $0.deletingPathExtension().lastPathComponent == "Podfile"
            }) {
                self.podURL = podfileURL
                self.hasPodfile = true
                let data = FileManager.default.contents(atPath: podfileURL.path)!
                let lines = String(data: data, encoding: .utf8)!.split(separator: "\n")
                for line in lines {
                    let splitLine = line.split(separator: " ")

                    let regex = try! NSRegularExpression(pattern: ".*pod ['\"].*['\"]")
                    let range = NSRange(location: 0, length: line.utf16.count)
                    guard regex.firstMatch(in: String(line), options: [], range: range) != nil else { continue }

                    if let podIndex = splitLine.firstIndex(of: "pod") {
                        var podName = splitLine[podIndex + 1]
                        podName.removeAll { $0 == "'" || $0 == "\"" || $0 == "," }
                        var pod = Pod(title: String(podName), version: "~> 1.0.0")
                        if splitLine.first == "#" {
                            pod.isEnabled = false
                        }
                        pods.append(pod)
                    }
                }
                pods.sort(by: { $0.name < $1.name} )
            } else {
                self.hasPodfile = false
            }
        } catch {
            print("Error while enumerating files \(selectedURL?.path ?? ""): \(error.localizedDescription)")
        }
    }
}
