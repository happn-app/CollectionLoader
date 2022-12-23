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



public protocol CollectionLoaderDelegate<CollectionLoaderHelper> : AnyObject {
	
	associatedtype CollectionLoaderHelper : CollectionLoaderHelperProtocol
	
	typealias PageInfo             = CollectionLoaderHelper.PageInfo
	typealias FetchedObject        = CollectionLoaderHelper.FetchedObject
	typealias CompletionResults    = CollectionLoaderHelper.CompletionResults
	typealias PreCompletionResults = CollectionLoaderHelper.PreCompletionResults
	
	@MainActor
	func didStartLoading(pageInfo: PageInfo)
	/** Throwing here will fail the import part of the loading operation. */
	func onContext_willFinishLoading(_ pageInfo: PageInfo, results: PreCompletionResults) throws
	@MainActor
	func didFinishLoading(_ pageInfo: PageInfo, results: Result<CompletionResults, Error>)
	
	func canDelete(object: FetchedObject) -> Bool
	
}


public extension CollectionLoaderDelegate {
	
	@MainActor
	func didStartLoading(pageInfo: PageInfo) {
	}
	
	func onContext_willFinishLoading(_ pageInfo: PageInfo, results: PreCompletionResults) throws {
	}
	
	@MainActor
	func didFinishLoading(_ pageInfo: PageInfo, results: Result<CompletionResults, Error>) {
	}
	
	func canDelete(object: FetchedObject) -> Bool {
		return true
	}

}
