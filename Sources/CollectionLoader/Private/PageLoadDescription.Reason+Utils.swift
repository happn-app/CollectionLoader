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



extension PageLoadDescription.Reason {
	
	@MainActor
	func operationLoadingDelegate<Helper : CollectionLoaderHelperProtocol>(with helper: Helper, pageLoadDescription: PageLoadDescription, delegate: (any CollectionLoaderDelegate<Helper>)?) -> some LoadingOperationDelegate<Helper.PreCompletionResults>
	where Helper.PageInfo == PageInfo, Helper.PageInfo == PageInfo {
		switch self {
			case .initialPage:             return Self.operationLoadingDelegateForInitialPage(       with: helper, pageLoadDescription: pageLoadDescription, delegate: delegate)
			case .nextPage, .previousPage: return Self.operationLoadingDelegateForNextOrPreviousPage(with: helper, pageLoadDescription: pageLoadDescription, delegate: delegate)
			case let .sync(range: range):  return Self.operationLoadingDelegateForSync(   of: range, with: helper, pageLoadDescription: pageLoadDescription, delegate: delegate)
		}
	}
	
	@MainActor
	private static func operationLoadingDelegateForInitialPage<Helper : CollectionLoaderHelperProtocol>(with helper: Helper, pageLoadDescription: PageLoadDescription, delegate: (any CollectionLoaderDelegate<Helper>)?) -> HandlerLoadingOperationDelegate<Helper.PreCompletionResults>
	where Helper.PageInfo == PageInfo, Helper.PageInfo == PageInfo {
		var objectsBeforeImport = Set<Helper.FetchedObject>()
		return HandlerLoadingOperationDelegate<Helper.PreCompletionResults>(
			willImport: { throwIfCancelled in
				let n = helper.onContext_numberOfObjects()
				for i in 0..<n {
					try throwIfCancelled()
					objectsBeforeImport.insert(helper.onContext_object(at: i))
				}
				return true
			},
			didFinishImport: { results, throwIfCancelled in
				/* Let’s remove all the objects from from the cache not in the results. */
				let n = helper.onContext_numberOfObjects(from: results)
				let objectsAfterImport = (0..<n).reduce(into: Set<Helper.FetchedObject>(), { $0.insert(helper.onContext_object(at: $1, from: results)) })
				for object in objectsBeforeImport.subtracting(objectsAfterImport) {
					guard Self.callCanDelete(on: delegate, object: object) else {
						continue
					}
					helper.onContext_delete(object: object)
					try throwIfCancelled()
				}
				
				try Self.callWillFinishLoading(on: delegate, pageLoadDescription: pageLoadDescription, results: results, cancellationCheck: throwIfCancelled)
			}
		)
	}
	
	@MainActor
	private static func operationLoadingDelegateForNextOrPreviousPage<Helper : CollectionLoaderHelperProtocol>(with helper: Helper, pageLoadDescription: PageLoadDescription, delegate: (any CollectionLoaderDelegate<Helper>)?) -> HandlerLoadingOperationDelegate<Helper.PreCompletionResults>
	where Helper.PageInfo == PageInfo, Helper.PageInfo == PageInfo {
		return HandlerLoadingOperationDelegate<Helper.PreCompletionResults>(
			didFinishImport: { results, throwIfCancelled in
				try Self.callWillFinishLoading(on: delegate, pageLoadDescription: pageLoadDescription, results: results, cancellationCheck: throwIfCancelled)
			}
		)
	}
	
	@MainActor
	private static func operationLoadingDelegateForSync<Helper : CollectionLoaderHelperProtocol>(of range: ClosedRange<Int>, with helper: Helper, pageLoadDescription: PageLoadDescription, delegate: (any CollectionLoaderDelegate<Helper>)?) -> HandlerLoadingOperationDelegate<Helper.PreCompletionResults>
	where Helper.PageInfo == PageInfo, Helper.PageInfo == PageInfo {
		var objectsBeforeStart = [Helper.FetchedObject]()
		return HandlerLoadingOperationDelegate<Helper.PreCompletionResults>(
			willStart: { throwIfCancelled in
				let n = helper.onContext_numberOfObjects()
				guard n > 0 else {return}
				
				for i in range.clamped(to: 0...(n-1)) {
					try throwIfCancelled()
					objectsBeforeStart.append(helper.onContext_object(at: i))
				}
			},
			willImport: { _ in
				return true
			},
			didFinishImport: { results, throwIfCancelled in
				try Self.callWillFinishLoading(on: delegate, pageLoadDescription: pageLoadDescription, results: results, cancellationCheck: throwIfCancelled)
			}
		)
	}
	
}


/* Extension to “unerase” the delegate.
 * Maybe some day in a future version of Swift these will not be required. */
extension PageLoadDescription.Reason {
	
	static func callCanDelete<Helper : CollectionLoaderHelperProtocol>(on delegate: (any CollectionLoaderDelegate<Helper>)?, object: Helper.FetchedObject) -> Bool {
		if let delegate {return callCanDelete(on: delegate, object: object)}
		else            {return true}
	}
	static func callCanDelete<Delegate : CollectionLoaderDelegate, Helper : CollectionLoaderHelperProtocol>(on delegate: Delegate, object: Helper.FetchedObject) -> Bool
	where Delegate.CollectionLoaderHelper == Helper {
		return delegate.onContext_canDelete(object: object)
	}
	
	static func callWillFinishLoading<Helper : CollectionLoaderHelperProtocol>(on delegate: (any CollectionLoaderDelegate<Helper>)?, pageLoadDescription: PageLoadDescription, results: Helper.PreCompletionResults, cancellationCheck throwIfCancelled: () throws -> Void) throws {
		if let delegate {
			try callWillFinishLoading(on: delegate, pageLoadDescription: pageLoadDescription, results: results, cancellationCheck: throwIfCancelled)
		}
	}
	static func callWillFinishLoading<Delegate : CollectionLoaderDelegate, Helper : CollectionLoaderHelperProtocol>(on delegate: Delegate, pageLoadDescription: PageLoadDescription, results: Helper.PreCompletionResults, cancellationCheck throwIfCancelled: () throws -> Void) throws
	where Delegate.CollectionLoaderHelper == Helper, Delegate.PageInfo == PageInfo {
		try delegate.onContext_willFinishLoading(pageLoadDescription: pageLoadDescription, results: results, cancellationCheck: throwIfCancelled)
	}
	
}
