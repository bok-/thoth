// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Thoth",
    
    platforms: [ .iOS(.v13), .macOS(.v10_15) ],
    
    products: [
        .library(name: "Thoth", targets: [ "Thoth" ] ),
        .executable(name: "Builder", targets: [ "Builder" ])
    ],
    
    dependencies: [
    ],
    
    targets: [
        .target(name: "Thoth", dependencies: [ "Config" ]),
        .target(name: "Builder", dependencies: [ "Config", "Thoth" ]),
        .target(name: "Config", dependencies: []),

        .testTarget(name: "ConfigTests", dependencies: [ "Config", "Thoth" ]),
    ]
)
