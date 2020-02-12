import XCTest

@testable import ConfigTests

var tests = [XCTestCaseEntry]()
tests += [ testCase(MenuTests.allTests) ]
XCTMain(tests)
