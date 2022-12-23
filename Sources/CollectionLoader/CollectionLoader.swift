/*
Copyright 2022 happn

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

import Foundation



public final class CollectionLoader<Helper : CollectionLoaderHelperProtocol> {
	
	public typealias PageInfo = Helper.PageInfo
	
	public let helper: Helper
	
	public weak var delegate: (any CollectionLoaderDelegate<Helper>)?
	
	public init(helper: Helper) {
		self.helper = helper
	}
	
	/**
	 Loads the initial page; the one when no page info is known, or when a complete reload is wanted.
	 
	 We did not name this `loadFirstPage` because if the collection is bidirectional, the initial page might not be the first. */
	func loadInitialPage() {
		load(pageInfo: helper.initialPageInfo())
	}
	
	func load(pageInfo: PageInfo) {
	}
	
}
