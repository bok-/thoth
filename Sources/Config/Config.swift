//
//  Config.swift
//

import Foundation

public class Config: Codable {
    
    public var content = Content()
    public var homeList = HomeList()
    public var menu = Menu()
    
    public init () {}
}
