//
//  MenuTests.swift
//

import XCTest
@testable import Config

public final class MenuTests: XCTestCase {
    
    static var allTests = [
        ("Menu cannot be empty", testMenuCannotBeEmpty),
    ]
    
    
    // MARK: - Tests
    
    func testMenuCannotBeEmpty() {
        let config = Config()
        XCTAssertFalse(config.menu.list.isEmpty, "Menu cannot be empty")
    }
}
