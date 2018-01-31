/*
 * CollectionLoaderHelper.swift
 * CollectionLoader
 *
 * Created by François Lamboley on 4/21/17.
 * Copyright © 2017 happn. All rights reserved.
 */

import Foundation

import AsyncOperationResult



public protocol CollectionLoaderHelper {
	
	associatedtype FetchedObjectsIDType : Hashable
	
	associatedtype CompletionResultsType
	associatedtype PreCompletionResultsType
	
	associatedtype PageInfoType
	
	associatedtype LoadingOperationType : Operation
	
	/** Return you page info for loading from the given start offset to the given
	end offset, both being inclusive. */
	func pageInfoFor(startOffset: Int, endOffset: Int) -> PageInfoType
	
	func operationForLoading(pageInfo: PageInfoType, preRun: (() -> Bool)?, preImport: (() -> Bool)?, preCompletion: ((_ results: PreCompletionResultsType) throws -> Void)?) -> LoadingOperationType
	func results(fromFinishedLoadingOperation operation: LoadingOperationType) -> AsyncOperationResult<CompletionResultsType>
	
	var numberOfCachedObjects: Int {get}
	func unsafeCachedObjectId(at index: Int) -> FetchedObjectsIDType
	
	func numberOfFetchedObjects(for preCompletionResults: PreCompletionResultsType) -> Int
	func unsafeFetchedObjectId(at index: Int, for preCompletionResults: PreCompletionResultsType) -> FetchedObjectsIDType
	
	func unsafeRemove(objectId: FetchedObjectsIDType, hardDelete: Bool)
	
	/* Return nil if you want the collection loader to infer the next page info
	 * from current page offsets.
	 * Return .some(nil) if you know there are no more pages to load.
	 * Return a PageInfo if you have a next page info. */
	func nextPageInfo(for completionResults: CompletionResultsType, from pageInfo: PageInfoType, nElementsPerPage: Int) -> PageInfoType??
	/* Return nil if you cannot retrieve a previous page.
	 * Return a page info type if you have a previous page info. */
	func previousPageInfo(for completionResults: CompletionResultsType, from pageInfo: PageInfoType, nElementsPerPage: Int) -> PageInfoType?
	
}
