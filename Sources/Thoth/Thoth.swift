//
//  Thoth.swift
//

import Foundation

#if os(iOS) || os(macOS)

import SwiftUI
@_exported import Config

@dynamicMemberLookup
public class Thoth: ObservableObject {

    enum Constants {
        static let url = URL(string: "https://cchmelb-demo.s3-ap-southeast-2.amazonaws.com/thoth.json")!
        static let refreshGranularity = Calendar.Component.second
        static let cacheFilename = "thoth.json"
    }
    
    
    // MARK: - Shared Instance
    
    /// I know.. I know..
    public static var shared = Thoth(url: ProcessInfo().environment["THOTH_URL"].flatMap(URL.init(string:)))

    
    // MARK: - Properties and Initialisation
    
    public var url: URL
    public var _config = Config()
    
    public init (url: URL? = nil) {
        self.url = url ?? Constants.url

        if let config = self.persisted() {
            self.apply(config: config)
        }

        self.refresh()
    }
    
    private func apply (config: Config) {
        DispatchQueue.main.async {
            self.objectWillChange.send()
            self._config = config
        }
    }
    
    
    // MARK: - Dynamic Member Lookup
    
    public subscript<ValueType> (dynamicMember keyPath: KeyPath<Config, ValueType>) -> ValueType {
        self.refreshIfNeeded()
        return self._config[keyPath: keyPath]
    }
    
 
    // MARK: - Refreshing
    
    private var refreshTime: Date?
    private var refreshInProgress = false
    
    /// Refreshes the Thoth only if the clock has moved on (e.g. if the hour has changed)
    ///
    private func refreshIfNeeded () {
        let calendar = Calendar(identifier: .gregorian)
        if let date = self.refreshTime, calendar.compare(date, to: Date(), toGranularity: Constants.refreshGranularity) != .orderedAscending {
            return
        }
        
        self.refresh()
    }
    
    /// Loads the thothured Thoth URL applies it to the receiver
    ///
    private func refresh () {
        guard self.refreshInProgress == false else { return }
        self.refreshInProgress = true

        var config = URLSessionConfiguration.ephemeral
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession(configuration: config)
        var request = URLRequest(url: self.url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            defer { self.refreshInProgress = false }

            if let error = error {
                print("[Thoth] Error refreshing configuration file at \(self.url): \(error)")
                return
            }
            
            guard let data = data else {
                print("[Thoth] Empty response: \(response?.description ?? "Empty URL Response")")
                return
            }
            
            do {
                let config = try Thoth.decoder.decode(Config.self, from: data)
                print("[Thoth] Refreshed config")
                self.apply(config: config)
                self.refreshTime = Date()

            } catch {
                print("[Thoth] Error decoding Config: \(error)")
            }
        }
        
        task.resume()
    }
    
    
    // MARK: - Caching
    
    /// Retrieves the cached copy of the Thoth from disk, if thtere is one
    ///
    private func persisted () -> Config? {
        let cache = Cache()
        guard let data = cache.get(filename: Constants.cacheFilename) else { return nil }
        
        return try? Thoth.decoder.decode(Config.self, from: data)
    }
    
    /// Caches the current state of the Thoth to disk
    ///
    private func persist () throws {
        let data = try Thoth.encoder.encode(self._config)
        
        let cache = Cache()
        try cache.set(filename: Constants.cacheFilename, data: data)
    }
}


// MARK: - Support For Linux

#else

public class Thoth {}

#endif


// MARK: - Encoding and Decoding

extension Thoth {
    public static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    public static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}
