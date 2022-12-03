// swift-tools-version:5.1
import PackageDescription


let package = Package(
	name: "CollectionLoader",
	products: [
		.library(name: "CollectionLoader", targets: ["CollectionLoader"]),
	],
	dependencies: [
		.package(url: "https://github.com/happn-app/KVObserver.git", from: "0.9.5")
	],
	targets: [
		.target(name: "CollectionLoader", dependencies: ["KVObserver"]),
		.testTarget(name: "CollectionLoaderTests", dependencies: ["CollectionLoader"])
	]
)
