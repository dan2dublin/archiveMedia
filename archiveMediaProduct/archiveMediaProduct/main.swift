//
//  main.swift
//  archiveMediaProduct
//
//  Created by Dan McSweeney on 8/31/25.
//

import Foundation

print("Hello, World!")

// The Swift Programming Language
// https://docs.swift.org/swift-book


import Foundation

// Define the source directories
let homeDir = FileManager.default.homeDirectoryForCurrentUser
let desktopDir = homeDir.appendingPathComponent("Desktop")
let moviesDir = homeDir.appendingPathComponent("Movies")

// Define the destination directory
//let toArchiveDir = URL(fileURLWithPath: "/users/danmcsweeney/Movies/toArchive", isDirectory: true)
let toArchiveDir = homeDir.appendingPathComponent("Movies/toArchive", isDirectory: true)

// File extensions to look for
let videoExtensions = ["mov", "mpg"]

// Function to move files
func moveVideos(from directory: URL) {
    let fm = FileManager.default
    do {
        let items = try fm.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        for item in items {
            if videoExtensions.contains(item.pathExtension.lowercased()) {
                let destURL = toArchiveDir.appendingPathComponent(item.lastPathComponent)
                do {
                    // Move the file
                    try fm.moveItem(at: item, to: destURL)
                    print("Moved \(item.path) to \(destURL.path)")
                } catch {
                    print("Failed to move \(item.path): \(error)")
                }
            }
        }
    } catch {
        print("Failed to list directory \(directory.path): \(error)")
    }
}

// Ensure destination directory exists
if !FileManager.default.fileExists(atPath: toArchiveDir.path) {
    do {
        try FileManager.default.createDirectory(at: toArchiveDir, withIntermediateDirectories: true, attributes: nil)
    } catch {
        print("Failed to create destination directory: \(error)")
        exit(1)
    }
}

// Move videos from Desktop and Movies (non-recursively)
moveVideos(from: desktopDir)
moveVideos(from: moviesDir)
