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
	/* About the 5 nbsp in the doc-comment below: I would want a new line.
	 * But with this SHITTY format that is markdown that seems impossible.
	 * (At least with Apple’s implementation of markdown.
	 *  But markdown is shitty anyways; all hail asciidoc!) */
	/**
	 Called when the loading of the page info has finished.
	 
	 In a normal scenario, the ``didStartLoading(pageInfo:)-203tu`` method is called first, then ``onContext_willFinishLoading(_:results:)-8num``, and then this method.
	 
	 - Important: There is a scenario where the two other methods might not be called and this one would be called directly:
	  if the helper fails retrieving the operation to load the given page info (``CollectionLoaderHelperProtocol/operationForLoading(pageInfo:delegate:)`` throws an error).
	 In this case, and in this case only, this method will be called _synchronously_, before the ``CollectionLoader/load(pageInfo:concurrentLoadBehavior:customOperationDependencies:)`` even returns.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	 This is also the only case where a page load delegate would be called out of order from the order they were started. */
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
