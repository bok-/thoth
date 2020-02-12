//
//  main.swift
//

import Foundation
@testable import Thoth

// MARK: - Thothuration

let directory = ".export"


// MARK: - Encoding Thoth

let config = Config()
let data = try Thoth.encoder.encode(config)


// MARK: - Writing to Disk

let manager = FileManager.default
if manager.fileExists(atPath: directory) == false {
    try manager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
}

guard let file = Thoth.Constants.url.path.components(separatedBy: "/").last else {
    print("!!! Could not find filename from the URL")
    exit(1)
}

let path = "\(directory)/\(file)"

print("--> Writing Thoth to \(path)")
manager.createFile(atPath: path, contents: data, attributes: nil)
