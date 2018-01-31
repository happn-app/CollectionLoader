// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription



let package = Package(
	name: "CollectionLoader",
	products: [
		.library(
			name: "CollectionLoader",
			targets: ["CollectionLoader"]
		)
	],
	dependencies: [
		.package(url: "git@github.com:happn-app/KVObserver.git", from: "0.9.0"),
		.package(url: "git@github.com:happn-app/AsyncOperationResult.git", from: "1.0.0")
	],
	targets: [
		.target(
			name: "CollectionLoader",
			dependencies: ["AsyncOperationResult", "KVObserver"]
		),
		.testTarget(
			name: "CollectionLoaderTests",
			dependencies: ["CollectionLoader"]
		)
	]
)
