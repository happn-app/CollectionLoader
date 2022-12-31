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
		$0.append(.library(name: "CollectionLoader",   targets: ["CollectionLoader"]))
		$0.append(.library(name: "BMOCoreDataLoaders", targets: ["BMOCoreDataLoaders"]))
	},
	
	
	dependencies: a{
		$0.append(.package(url: "https://github.com/happn-app/BMO.git", .branch("dev.bmo2")))
	},
	
	
	targets: a{
		$0.append(.target(name: "CollectionLoader", dependencies: a{ _ in
		}))
		$0.append(.testTarget(name: "CollectionLoaderTests", dependencies: ["CollectionLoader"]))
		
		$0.append(.target(name: "BMOCoreDataLoaders", dependencies: a{
			$0.append(.product(name: "BMOCoreData", package: "BMO"))
			$0.append(.target(name: "CollectionLoader"))
		}))
	}
)
