// swift-tools-version:5.0
import PackageDescription


let package = Package(
	name: "CollectionLoader",
	platforms: [
		.macOS(.v10_10),
		.iOS(.v8),
		.tvOS(.v9),
		.watchOS(.v2)
	],
	products: [
		.library(name: "CollectionLoader", targets: ["CollectionLoader"]),
	],
	dependencies: [
		.package(url: "https://github.com/happn-tech/KVObserver.git", from: "0.9.4"),
		.package(url: "https://github.com/happn-tech/AsyncOperationResult.git", from: "1.0.5")
	],
	targets: [
		.target(name: "CollectionLoader", dependencies: ["AsyncOperationResult", "KVObserver"]),
		.testTarget(name: "CollectionLoaderTests", dependencies: ["CollectionLoader"])
	]
)
