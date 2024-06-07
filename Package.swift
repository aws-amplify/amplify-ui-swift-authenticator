// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AmplifyUIAuthenticator",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(
            name: "Authenticator",
            targets: ["Authenticator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/aws-amplify/amplify-swift", from: "2.35.0"),
    ],
    targets: [
        .target(
            name: "Authenticator",
            dependencies: [
                .product(name: "Amplify", package: "amplify-swift"),
                .product(name: "AWSCognitoAuthPlugin", package: "amplify-swift")
            ]),
        .testTarget(
            name: "AuthenticatorTests",
            dependencies: ["Authenticator"]),
    ]
)
