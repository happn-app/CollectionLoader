Pod::Spec.new do |spec|
	spec.name = "CollectionLoader"
	spec.version = "0.9.2"
	spec.summary = "Loading collections of objects by page, coming from arbitrary data sources"
	spec.homepage = "https://www.happn.com/"
	spec.license = {type: 'TBD', file: 'License.txt'}
	spec.authors = {"François Lamboley" => 'francois.lamboley@happn.com'}
	spec.social_media_url = "https://twitter.com/happn_tech"

	spec.requires_arc = true
	spec.source = {git: "git@github.com:happn-app/CollectionLoader.git", tag: spec.version}
	spec.source_files = "Sources/CollectionLoader/*.swift"

	spec.ios.deployment_target = '8.0'
	spec.osx.deployment_target = '10.9'
	spec.tvos.deployment_target = '9.0'
	spec.watchos.deployment_target = '2.0'

	spec.dependency "KVObserver", "~> 0.9.0"
	spec.dependency "AsyncOperationResult", "~> 1.0.0"
end
