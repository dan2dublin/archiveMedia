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

// Define the destination directory using the current user's home directory
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
                //    try fm.moveItem(at: item, to: destURL)
                    try fm.copyItem(at: item, to: destURL)
                    print("Copied \(item.path) to \(destURL.path)")
                } catch {
                    print("Failed to Copy \(item.path): \(error)")
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

// After copying, move the toArchive folder to the SMB server
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
let dateString = dateFormatter.string(from: Date())
let serverFolderName = "video_" + dateString

// SMB mount point (assumes already mounted at /Volumes)
let smbMountPoint = "/Volumes/Public" // Change if your mount point is different
let serverDestDir = URL(fileURLWithPath: smbMountPoint).appendingPathComponent(serverFolderName, isDirectory: true)

let fm = FileManager.default
do {
    // Create the destination folder on the server
    try fm.createDirectory(at: serverDestDir, withIntermediateDirectories: true, attributes: nil)
    // Move the toArchive folder to the server destination
    let finalDest = serverDestDir.appendingPathComponent("toArchive", isDirectory: true)
    try fm.moveItem(at: toArchiveDir, to: finalDest)
    print("Moved toArchive to \(finalDest.path)")
} catch {
    print("Failed to move toArchive to server: \(error)")
}
