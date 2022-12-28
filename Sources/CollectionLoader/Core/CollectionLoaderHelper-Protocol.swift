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



public protocol CollectionLoaderHelperProtocol {
	
	/**
	 The type of the page info, which represent a given page. */
	associatedtype PageInfo : PageInfoProtocol
	
	/** The type of the objects in the collection. */
	associatedtype FetchedObject : Hashable
	
	/**
	 The operation to be launched to load a given page info.
	 
	 This is an associated type because after being asked the operation to load a given page info,
	  the helper will be asked for the results from a finished operation.
	 The associatedtype make the helper sure the operation will be of the expected type. */
	associatedtype LoadingOperation : Operation
	
	/** The successful results from a finished loading operation, from inside the db context. */
	associatedtype PreCompletionResults
	/**
	 The successful results from a finished loading operation, retrieved out of the db context.
	 Can be the same as the PreCompletionResults (will likely always be the same actually). */
	associatedtype CompletionResults
	
	/* *************************
	   MARK: Get Current Objects
	   ************************* */
	
	/** Return the number of objects currently in the collection. */
	func onContext_numberOfObjects() -> Int
	/** Return an object in the collection at a given index. */
	func onContext_object(at index: Int) -> FetchedObject
	
	/* *********************************************
	   MARK: Get Objects from Pre-Completion Results
	   ********************************************* */
	
	/** Return the number of objects in the pre-completion result. */
	func onContext_numberOfObjects(from preCompletionResults: PreCompletionResults) -> Int
	/** Return an object at a given index in the collection from the pre-completion result. */
	func onContext_object(at index: Int, from preCompletionResults: PreCompletionResults) -> FetchedObject
	
	/* ****************
	   MARK: Load Pages
	   **************** */
	
	/**
	 Return the operation for loading the given page info.
	 
	 When launched, the operation is responsible for loading the page represented by the given page info.
	 
	 - Important: A successful operation **should** have called all of the methods of the given delegate at the appropriate times.
	 Indeed, most of the work of the ``CollectionLoader`` happens inside these calls. */
	func operationForLoading(pageInfo: PageInfo, delegate: any LoadingOperationDelegate<PreCompletionResults>) throws -> LoadingOperation
	func results(from finishedLoadingOperation: LoadingOperation) -> Result<CompletionResults, Error>
	
	/* *************************
	   MARK: Getting Pages Infos
	   ************************* */
	
	func initialPageInfo() -> PageInfo
	func nextPageInfo(    for completionResults: CompletionResults, from pageInfo: PageInfo) -> PageInfo?
	func previousPageInfo(for completionResults: CompletionResults, from pageInfo: PageInfo) -> PageInfo?
	
}
