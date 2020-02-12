//
//  Cache.swift
//

import Foundation

final class Cache {
    
    private enum Constants {
        static let directoryName = "thoth"
    }

    
    // MARK: - Dependencies and Initialisation
    
    init () {
    }
    
    func get (filename: String) -> Data? {
        guard let directory = try? Cache.cacheDirectory() else { return nil }
        let file = (directory as NSString).appendingPathComponent(filename)
        return FileManager.default.contents(atPath: file)
    }

    func set (filename: String, data: Data) throws {
        let directory = try Cache.cacheDirectory()
        let file = (directory as NSString).appendingPathComponent(filename)
        let url = URL(fileURLWithPath: file)
        try data.write(to: url)
    }

    
    // MARK: - Private Helpers
    
    private static func cacheDirectory () throws -> String {
        let manager = FileManager.default
        guard let directory = manager.urls(for: .cachesDirectory, in: .userDomainMask).first?.path else {
            throw Error.couldNotFindCachesDirectory
        }
        
        let target = (directory as NSString).appendingPathComponent(Constants.directoryName)
        var isDirectory: ObjCBool = false
        if manager.fileExists(atPath: target, isDirectory: &isDirectory) {
            guard manager.isReadableFile(atPath: target) == true else { throw Error.couldNotCreateCachesDirectory(underlying: nil) }
            
            // all good
            if isDirectory.boolValue == true {
                return target
                
            // not a directory, can we delete it?
            } else if manager.isDeletableFile(atPath: target) {
                try manager.removeItem(atPath: target)

            // screwed!
            } else {
                throw Error.couldNotCreateCachesDirectory(underlying: nil)
            }
        }
        
        // create and return
        do {
            try manager.createDirectory(atPath: target, withIntermediateDirectories: true, attributes: nil)
            return target

        } catch {
            throw Error.couldNotCreateCachesDirectory(underlying: error)
        }
    }
    
    
    // MARK: - Errors

    public enum Error: Swift.Error {
        case couldNotFindCachesDirectory
        case couldNotCreateCachesDirectory (underlying: Swift.Error?)
    }
}
