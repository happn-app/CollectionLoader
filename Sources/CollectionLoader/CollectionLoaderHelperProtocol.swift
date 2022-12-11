/*
Copyright 2019 happn

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



public protocol CollectionLoaderHelperProtocol {
	
	associatedtype FetchedObjectID : Hashable
	
	associatedtype CompletionResults
	associatedtype PreCompletionResults
	
	associatedtype PageInfo
	
	associatedtype LoadingOperation : Operation
	
	/**
	 Return you page info for loading from the given start offset to the given end offset, both being inclusive. */
	func pageInfoFor(startOffset: Int, endOffset: Int) -> PageInfo
	
	func operationForLoading(pageInfo: PageInfo, preRun: (() -> Bool)?, preImport: (() -> Bool)?, preCompletion: ((_ results: PreCompletionResults) throws -> Void)?) -> LoadingOperation
	func results(fromFinishedLoadingOperation operation: LoadingOperation) -> Result<CompletionResults, Error>
	
	var numberOfCachedObjects: Int {get}
	func unsafeCachedObjectID(at index: Int) -> FetchedObjectID
	
	func numberOfFetchedObjects(for preCompletionResults: PreCompletionResults) -> Int
	func unsafeFetchedObjectID(at index: Int, for preCompletionResults: PreCompletionResults) -> FetchedObjectID
	
	func unsafeRemove(objectID: FetchedObjectID, hardDelete: Bool)
	
	/* Return nil if you want the collection loader to infer the next page info from current page offsets.
	 * Return .some(nil) if you know there are no more pages to load.
	 * Return a PageInfo if you have a next page info. */
	func nextPageInfo(for completionResults: CompletionResults, from pageInfo: PageInfo, nElementsPerPage: Int) -> PageInfo??
	/* Return nil if you cannot retrieve a previous page.
	 * Return a page info type if you have a previous page info. */
	func previousPageInfo(for completionResults: CompletionResults, from pageInfo: PageInfo, nElementsPerPage: Int) -> PageInfo?
	
}
