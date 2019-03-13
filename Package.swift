// swift-tools-version:4.0

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
		.package(url: "git@github.com:happn-tech/KVObserver.git", from: "0.9.4"),
		.package(url: "git@github.com:happn-tech/AsyncOperationResult.git", from: "1.0.5")
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
