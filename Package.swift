// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReMVVM",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ReMVVM",
            targets: ["ReMVVM"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/dgrzeszczak/MVVM", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ReMVVM",
            dependencies: ["MVVM"],
            path: "ReMVVM/Sources",
            exclude: [
                "Submodules/SwiftyRedux/SwiftyRedux/Sources/StoreState.swift",
                "Submodules/SwiftyRedux/SwiftyReduxTests/"]),
//        .testTarget(
//            name: "ReMVVMTests",
//            dependencies: ["ReMVVM"],
//            path: "ReMVVMTests"),
    ]
)
