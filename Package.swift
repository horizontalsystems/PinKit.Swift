// swift-tools-version:5.5

import PackageDescription

let package = Package(
        name: "PinKit",
        defaultLocalization: "en",
        platforms: [
            .iOS(.v13),
        ],
        products: [
            .library(
                    name: "PinKit",
                    targets: ["PinKit"]),
        ],
        dependencies: [
            .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.1")),
            .package(url: "https://github.com/horizontalsystems/LanguageKit.Swift.git", .upToNextMajor(from: "1.0.0")),
            .package(url: "https://github.com/horizontalsystems/StorageKit.Swift.git", .upToNextMajor(from: "1.0.0")),
        ],
        targets: [
            .target(
                    name: "PinKit",
                    dependencies: [
                        "RxSwift",
                        .product(name: "RxCocoa", package: "RxSwift"),
                        .product(name: "LanguageKit", package: "LanguageKit.Swift"),
                        .product(name: "StorageKit", package: "StorageKit.Swift"),
                    ]
            ),
        ]
)
