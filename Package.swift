// swift-tools-version:5.1
import PackageDescription
func buildArray<Element>(of type: Any.Type = Element.self, _ builder: (_ collection: inout [Element]) -> Void) -> [Element] {
	var ret = [Element](); builder(&ret); return ret
}



let package = Package(
	name: "CollectionLoader",
	
	
	products: buildArray{
		$0.append(.library(name: "CollectionLoader", targets: ["CollectionLoader"]))
	},
	
	
	dependencies: buildArray{
		$0.append(.package(url: "https://github.com/happn-app/KVObserver.git", from: "0.9.5"))
	},
	
	
	targets: buildArray{
		$0.append(.target(name: "CollectionLoader", dependencies: buildArray{
			$0.append(.product(name: "KVObserver", package: "KVObserver"))
		}))
		$0.append(.testTarget(name: "CollectionLoaderTests", dependencies: ["CollectionLoader"]))
	}
)
