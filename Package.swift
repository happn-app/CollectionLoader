// swift-tools-version:5.1
import PackageDescription
func a<Element>(of type: Any.Type = Element.self, _ builder: (_ collection: inout [Element]) -> Void) -> [Element] {
	var ret = [Element](); builder(&ret); return ret
}



let package = Package(
	name: "CollectionLoader",
	
	
	platforms: [
		.macOS(.v10_15),
		.tvOS(.v13),
		.iOS(.v13),
		.watchOS(.v6)
	],
	
	
	products: a{
		$0.append(.library(name: "CollectionLoader", targets: ["CollectionLoader"]))
	},
	
	
	dependencies: a{ r in
	},
	
	
	targets: a{
		$0.append(.target(name: "CollectionLoader", dependencies: a{ _ in
		}))
		$0.append(.testTarget(name: "CollectionLoaderTests", dependencies: ["CollectionLoader"]))
	}
)
