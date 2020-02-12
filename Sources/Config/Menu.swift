//
//  Menu.swift
//

import Foundation

public struct Menu: Codable {
    public var list: [MenuItem] = [
        MenuItem(title: "My Account", icon: "person.crop.circle"),
        MenuItem(title: "Settings", icon: "gear"),
        MenuItem(title: "Billing", icon: "creditcard"),
        MenuItem(title: "Team", icon: "person.2"),
        MenuItem(title: "Sign out", icon: "arrow.uturn.down")
    ]
}

public struct MenuItem: Codable, Identifiable {
    public let id = UUID()
    public let title: String
    public let icon: String
}
