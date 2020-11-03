// swift-tools-version:5.1
import PackageDescription


let package = Package(
	name: "CollectionLoader",
	products: [
		.library(name: "CollectionLoader", targets: ["CollectionLoader"]),
	],
	dependencies: [
		.package(url: "https://github.com/happn-tech/KVObserver.git", from: "0.9.5"),
		.package(url: "https://github.com/happn-tech/AsyncOperationResult.git", from: "1.0.6")
	],
	targets: [
		.target(name: "CollectionLoader", dependencies: ["AsyncOperationResult", "KVObserver"]),
		.testTarget(name: "CollectionLoaderTests", dependencies: ["CollectionLoader"])
	]
)
