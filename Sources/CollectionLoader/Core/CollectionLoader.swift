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



@MainActor
public final class CollectionLoader<Helper : CollectionLoaderHelperProtocol> {
	
	public typealias PageInfo = Helper.PageInfo
	public typealias CLPageLoadDescription = PageLoadDescription<PageInfo>
	
	public let helper: Helper
	/**
	 The queue on which the loading operations are launched.
	 There are no restrictions on the `maxConcurrentOperationCount` of the queue. */
	public let operationQueue: OperationQueue
	
	public weak var delegate: (any CollectionLoaderDelegate<Helper>)?
	
	public init(helper: Helper, operationQueue: OperationQueue = OperationQueue()) {
		self.helper = helper
		self.operationQueue = operationQueue
	}
	
	/**
	 Loads the initial page; the one when no page info is known, or when a complete reload is wanted.
	 
	 We did not name this `loadFirstPage` because if the collection is bidirectional, the initial page might not be the first. */
	public func loadInitialPage() {
		let pld = CLPageLoadDescription(loadedPage: helper.initialPageInfo(), loadingReason: .initialPage)
		load(pageLoadDescription: pld, concurrentLoadBehavior: .cancelAllOther)
	}
	
	/**
	 Only one page load at a time is allowed.
	 All of the loading operations are launched in a queue with a maximum concurrent operation count set to 1. */
	public func load(pageLoadDescription: CLPageLoadDescription, concurrentLoadBehavior: ConcurrentLoadBehavior = .queue, customOperationDependencies: [Operation] = []) {
		/* We capture the delegate so we always get the same one for all the callbacks.
		 * We do not capture the handler because we do not need it here (only used in the loading delegate). */
		let delegate = delegate
		
		let operation: Helper.LoadingOperation
		let loadingDelegate = pageLoadDescription.loadingReason.operationLoadingDelegate(with: helper, pageLoadDescription: pageLoadDescription, delegate: delegate)
		do    {operation = try helper.operationForLoading(pageInfo: pageLoadDescription.loadedPage, delegate: loadingDelegate)}
		catch {Self.callDidFinishLoading(on: delegate, pageLoadDescription: pageLoadDescription, results: .failure(error)); return}
		
		/* We capture the delegate to always get the same one for all the callbacks. */
		let prestart = BlockOperation{ [weak self, delegate] in
			/* On main queue (and thus on main actor/thread). */
			/* Let’s call the delegate first. */
			Self.callWillStartLoading(on: delegate, pageLoadDescription: pageLoadDescription)
			
			/* Then we remove ourselves from the pending operations and put ourselves as the current operation instead.
			 * By construction, our operation is the first one of the pending operations. */
			guard let self else {return}
			assert(self.currentOperation == nil)
			self.currentOperation = self.pendingOperations.removeFirst() /* Crashes if pendingOperations is empty, which is what we want. */
		}
		/* We capture the delegate to always get the same one for all the callbacks. */
		let completion = BlockOperation{ [weak self, delegate, helper] in
			/* On main queue (and thus on main actor/thread). */
			/* Let’s call the delegate first. */
			Self.callDidFinishLoading(on: delegate, pageLoadDescription: pageLoadDescription, results: helper.results(from: operation))
			
			/* Then we remove ourselves as the current operation. */
			guard let self else {return}
			self.currentOperation = nil
		}
		
		switch concurrentLoadBehavior {
			case .queue:          (/*nop*/)
			case .cancelAllOther: currentOperation?.cancel(); fallthrough
			case .replaceQueue:   pendingOperations.forEach{ $0.cancel() }
		}
		
		let loadingOperations = LoadingOperations(prestart: prestart, loading: operation, completion: completion)
		loadingOperations.setupDependencies(previousOperations: pendingOperations.last ?? currentOperation)
		loadingOperations.prestart.addDependencies(customOperationDependencies)
		pendingOperations.append(loadingOperations)
		
		operationQueue.addOperations([operation], waitUntilFinished: false)
		OperationQueue.main.addOperations([prestart, completion], waitUntilFinished: false)
	}
	
	/* ***************
	   MARK: - Private
	   *************** */
	
	/* No lock for either vars, because only accessed/modified on main actor. */
	private var currentOperation: LoadingOperations?
	private var pendingOperations = [LoadingOperations]()
	
	@MainActor
	private struct LoadingOperations {
		
		let prestart:   Operation
		let loading:    Operation
		let completion: Operation
		
		func setupDependencies(previousOperations: LoadingOperations?) {
			if let previousOperations {
				/* The new loading can only be started if all the previously launched loadings are finished (either by truly finished or by being cancelled).
				 * As this is true for all loadings, adding a dependency only on the completion of the previous loading is enough. */
				prestart.addDependency(previousOperations.completion)
			}
			loading.addDependency(prestart)
			completion.addDependency(loading)
		}
		
		func cancel() {
			/* We do NOT cancel the prestart and completion operations.
			 * If we did, we could get missing notifications in the delegate, which we want to avoid.
			 *
			 * This would happen because
			 *   1/ cancelled operation’s dependencies are ignored and
			 *   2/ the start() method finishes the operation without even launching it for most operations
			 *       (tested for a block operation: if it is cancelled when added in the queue, the block will not run).
			 *
			 * So for instance if the prestart operation has run but the loading operation is still in progress while a group is cancelled,
			 *  the completion operation would be completely skipped and the delegate would not be called. */
			loading.cancel()
		}
		
	}
	
}


/* Extension to “unerase” the delegate.
 * Maybe some day in a future version of Swift these will not be required. */
private extension CollectionLoader {
	
	private static func callWillStartLoading(on delegate: (any CollectionLoaderDelegate<Helper>)?, pageLoadDescription: CLPageLoadDescription) {
		if let delegate {
			callWillStartLoading(on: delegate, pageLoadDescription: pageLoadDescription)
		}
	}
	private static func callWillStartLoading<Delegate : CollectionLoaderDelegate>(on delegate: Delegate, pageLoadDescription: CLPageLoadDescription)
	where Delegate.CollectionLoaderHelper == Helper {
		delegate.willStartLoading(pageLoadDescription: pageLoadDescription)
	}
	
	private static func callDidFinishLoading(on delegate: (any CollectionLoaderDelegate<Helper>)?, pageLoadDescription: CLPageLoadDescription, results: Result<Helper.CompletionResults, Error>) {
		if let delegate {
			callDidFinishLoading(on: delegate, pageLoadDescription: pageLoadDescription, results: results)
		}
	}
	private static func callDidFinishLoading<Delegate : CollectionLoaderDelegate>(on delegate: Delegate, pageLoadDescription: CLPageLoadDescription, results: Result<Helper.CompletionResults, Error>)
	where Delegate.CollectionLoaderHelper == Helper {
		delegate.didFinishLoading(pageLoadDescription: pageLoadDescription, results: results)
	}
	
}
