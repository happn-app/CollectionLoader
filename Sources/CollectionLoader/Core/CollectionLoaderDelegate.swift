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
	
	typealias PageInfo               = CollectionLoaderHelper.PageInfo
	typealias FetchedObject          = CollectionLoaderHelper.FetchedObject
	typealias CompletionResults      = CollectionLoaderHelper.CompletionResults
	typealias PreCompletionResults   = CollectionLoaderHelper.PreCompletionResults
	/* Note: We would want to name this typealias PageLoadDescription but it’s not possible because CollectionLoader.PageLoadDescription fails to resolve (Swift tries to find the PageLoadDescription type inside the CollectionLoader *class* instead of the module). */
	typealias CLDPageLoadDescription = PageLoadDescription<PageInfo>
	
	@MainActor
	func willStartLoading(pageLoadDescription: CLDPageLoadDescription)
	/**
	 Called when the loading of the page info has finished.
	 
	 In a normal scenario, the ``willStartLoading(pageLoadDescription:)-8cxld`` method is called first, then optionally ``onContext_willFinishLoading(pageLoadDescription:results:cancellationCheck:)-95bs3``, and then this method.
	 
	 There is a scenario where ``willStartLoading(pageLoadDescription:)-8cxld`` might not be called though:
	  if the helper fails retrieving the operation to load the given page info (``CollectionLoaderHelperProtocol/operationForLoading(pageInfo:delegate:)`` throws an error).
	 In this case, and in this case only, this method will be called _synchronously_, before the ``CollectionLoader/load(pageLoadDescription:concurrentLoadBehavior:customOperationDependencies:)`` even returns.
	 
	 This is also the only case where a page load delegate method would be called for a page info out of order from the order it was sent. */
	@MainActor
	func didFinishLoading(pageLoadDescription: CLDPageLoadDescription, results: Result<CompletionResults, Error>)
	
	/**
	 Return `false` to prevent the deletion of a fetched object that should be deleted if the page load went normally.
	 
	 When the loading operation finishes, depending on the reason of the loading, some objects might be deleted from the collection.
	 
	 For instance for an initial page load, all objects in the collection _not_ in the objects returned by the loading operation should be deleted.
	 
	 By implementing this method you can prevent the removal of some objects. */
	func onContext_canDelete(object: FetchedObject) -> Bool
	
	/**
	 Called _just_ before the loading operation finishes, just after the objects are imported in the local db.
	 
	 Throwing here will fail the import part of the loading operation.
	 
	 If the `cancellationCheck` block throws, you should stop your actions as soon as possible.
	 
	 This might not be called if the operation fails before reaching this point (including cancellation). */
	func onContext_willFinishLoading(pageLoadDescription: CLDPageLoadDescription, results: PreCompletionResults, cancellationCheck throwIfCancelled: () throws -> Void) throws
	
}


public extension CollectionLoaderDelegate {
	
	@MainActor
	func willStartLoading(pageLoadDescription: CLDPageLoadDescription) {
	}
	
	@MainActor
	func didFinishLoading(pageLoadDescription: CLDPageLoadDescription, results: Result<CompletionResults, Error>) {
	}
	
	func onContext_canDelete(object: FetchedObject) -> Bool {
		return true
	}
	
	func onContext_willFinishLoading(pageLoadDescription: CLDPageLoadDescription, results: PreCompletionResults, cancellationCheck throwIfCancelled: () throws -> Void) throws {
	}
	
}
