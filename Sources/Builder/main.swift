//
//  main.swift
//

import Foundation
import Config
import Thoth

// MARK: - Thothuration

let directory = ".export"
let file = "thoth.json"


// MARK: - Encoding Thoth

let config = Config()
let data = try Thoth.encoder.encode(config)


// MARK: - Writing to Disk

let manager = FileManager.default
if manager.fileExists(atPath: directory) == false {
    try manager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
}

let path = "\(directory)/\(file)"

print("--> Writing Thoth to \(path)")
manager.createFile(atPath: path, contents: data, attributes: nil)
