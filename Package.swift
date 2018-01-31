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
	],
	targets: [
		.target(
			name: "CollectionLoader",
			dependencies: []
		),
		.testTarget(
			name: "CollectionLoaderTests",
			dependencies: ["CollectionLoader"]
		)
	]
)
