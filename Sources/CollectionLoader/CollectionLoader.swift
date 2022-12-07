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

import KVObserver



public final class CollectionLoader<CollectionLoaderHelper : CollectionLoaderHelperProtocol> {
	
	public enum LastPageDetectionMethod {
		case retrievedIncompletePage
		case retrievedLessOrExactly(Int)
		case custom(handler: (_ preresults: CollectionLoaderHelper.PreCompletionResults) -> Bool) /* Return true if last page. */
	}
	
	/* **************************
	   MARK: - Config (Read-Only)
	   ************************** */
	
	public let helper: CollectionLoaderHelper
	
	public let numberOfElementsPerPage: Int
	/* Only used if the helper does not return a next page. */
	public let lastPageDetectionMethod: LastPageDetectionMethod
	
	/* ***************************
	   MARK: - Config (Read-Write)
	   *************************** */
	
	/**
	 This handler is called by the collection loader when the loading of a page has started.
	 Always called on the main thread. */
	public var didStartLoadingPageHandler: (() -> Void)?
	
	/**
	 This handler is called by the collection loader in the preCompletion state for a page loading
	  (loading is not over, but data from the back has been fetched and parsed). */
	public var willFinishLoadingPageHandler: ((_ preresults: CollectionLoaderHelper.PreCompletionResults, _ pageInfo: CollectionLoaderHelper.PageInfo, _ offsets: (start: Int, end: Int)?) throws -> Void)?
	
	/**
	 This handler is called by the collection loader when the loading of a page is finished.
	 Always called on the main thread. */
	public var didFinishLoadingPageHandler: ((_ results:  Result<CollectionLoaderHelper.CompletionResults, Error>?) -> Void)?
	
	/**
	 This handler is called by the collection loader in the preCompletion state for a sync
	  (loading is not over, but data from the back has been fetched and parsed). */
	public var willFinishSyncHandler: ((CollectionLoaderHelper.PreCompletionResults) throws -> Void)?
	
	/**
	 These handlers are called by the collection loader when its loading state changes.
	 Always called on the main thread. */
	public var isLoadingPageChangedHandler: (() -> Void)?
	public var isLoadingPageChangedHandler2: (() -> Void)?
	
	/**
	 This handler is called by the collection loader when the `isLoadingFirstPage` property changes.
	 Always called on the main thread. */
	public var isLoadingFirstPageChangedHandler: (() -> Void)?
	
	public var canDeleteObjectIdHandler: ((_ objectId: CollectionLoaderHelper.FetchedObjectID) -> Bool)?
	
	/* ********************
	   MARK: - Loader State
	   ******************** */
	
	/**
	 `true` if the last page was not reached. */
	public var hasMore: Bool = true
	
	/**
	 `true` if loading a page, `false` otherwise. Guaranteed to change on the main thread.
	 
	 Will not change when syncing. */
	public var isLoadingPage: Bool = false
	
	/**
	 `true` if loading first page, `false otherwise.
	 
	 Will not change when syncing. */
	public var isLoadingFirstPage: Bool = false
	
	/**
	 The date of the latest successful page load. Might be nil if no page was ever successful loaded yet. */
	public var dateLastSuccessfulLoad: Date? = nil
	
	/**
	 The error from the latest page load. `nil` if no errors occurred. */
	public var lastLoadError: Error? = nil
	
#if !NO_HAPPSIGHT
	/**
	 The latest loaded page #, nil if no pages have been loaded yet.
	 This is used internally by happn for data only.
	 Please do not use, it will be removed in a future release. */
	public var lastLoadedPageNumber: Int?
	private var nextPage = 0
#endif
	
	/* ************
	   MARK: - Init
	   ************ */
	
	public init(collectionLoaderHelper clh: CollectionLoaderHelper, numberOfElementsPerPage npp: Int, lastPageDetectionMethod lpdm: LastPageDetectionMethod = .retrievedIncompletePage) {
		helper = clh
		numberOfElementsPerPage = npp
		lastPageDetectionMethod = lpdm
	}
	
	deinit {
		kvObserver.stopObservingEverything()
	}
	
	/* ******************************************
	   MARK: - Actions (Must Call on Main Thread)
	   ****************************************** */
	
	/**
	 Loads the page with the given index (first is 0).
	 
	 - Parameter force: If loader is loading a page, the current loading will be cancelled if `force` is set to true.
	 Otherwise nothing will be done.
	 - Returns: `false` if loader was already loading when the method was called. */
	@discardableResult
	public func loadFirstPage(force: Bool = false) -> Bool {
#if !NO_HAPPSIGHT
		nextPage = 0
#endif
		return load(pageLoadDescription: PageLoadDescription(forFirstPageWithHelper: helper, numberOfElementsPerPage: numberOfElementsPerPage), force: force)
	}
	
	/**
	 Loads the page after the latest successfully loaded page.
	 
	 - Parameter force: If loader is loading, the current loading will be cancelled if `force` is set to true.
	 Otherwise nothing will be done.
	 - Returns: `false` if loader was already loading when the method was called. */
	@discardableResult
	public func loadNextPage(force: Bool = false) -> Bool {
		guard let nextPageInfo = nextPageInfo else {return !isLoadingPage}
		return load(pageLoadDescription: PageLoadDescription(forNextPageWithHelper: helper, nextPageInfo: nextPageInfo), force: force)
	}
	
	/**
	 Loads the page before the first page, or the latest "previous" page load.
	 Useful if you want to fetch new data in a timeline without loading the first page (which drops the rest of the timeline).
	 
	 - Parameter force: If loader is loading, the current loading will be cancelled if `force` is set to true.
	 Otherwise nothing will be done.
	 - Returns: `false` if loader was already loading when the method was called. */
	@discardableResult
	public func loadPreviousPage(force: Bool = false) -> Bool {
		guard let previousPageInfo = previousPageInfo else {return !isLoadingPage}
		return load(pageLoadDescription: PageLoadDescription(forPreviousPageWithHelper: helper, previousPageInfo: previousPageInfo), force: force)
	}
	
	/**
	 Cancels the current page loading if any.
	 
	 - Returns: `true` if loader was already loading when the method was called. */
	@discardableResult
	public func cancelCurrentPageLoading() -> Bool {
		assert(Thread.isMainThread)
		
		let wasLoading = isLoadingPage
		endOperationCheck = nil
		pageLoadingQueue.cancelAllOperations()
		return wasLoading
	}
	
	@discardableResult
	public func sync(from: Int, to: Int, force: Bool = false) -> Bool {
		assert(Thread.isMainThread)
		precondition(false, "Not Implemented Yet")
		
		let wasLoading = syncQueue.operationCount > 0
		if wasLoading {guard force else {return false}}
		syncQueue.cancelAllOperations()
		
		let to = to + 7
		let from = max(0, from - 7)
		
		let preRunHandler = { () -> Bool in
			/* TODO: Retrieve the object ids in the cache (we’re _before_ running the operation). */
			return true
		}
		let preImportHandler = { () -> Bool in
			/* TODO: Retrieve the object ids in the cache.
			 * If the ids are different than the one fetched in the pre-run handler we cancel the sync
			 *  (the cached objects have been modified while the objects for the sync were loading; the sync would not have much meaning…) */
			return true
		}
		let preCompletionHandler = { (_ preresults: CollectionLoaderHelper.PreCompletionResults) -> Void in
			/* TODO: The actual sync. */
		}
		
		let operation = helper.operationForLoading(pageInfo: helper.pageInfoFor(startOffset: from, endOffset: to), preRun: preRunHandler, preImport: preImportHandler, preCompletion: preCompletionHandler)
		syncQueue.addOperation(operation)
		return !wasLoading
	}
	
	/**
	 Cancels the current sync if any.
	 
	 - Returns: `true` if loader was already syncing when the method was called. */
	@discardableResult
	public func cancelCurrentSync() -> Bool {
		assert(Thread.isMainThread)
		
		let wasLoading = syncQueue.operationCount > 0
		syncQueue.cancelAllOperations()
		return wasLoading
	}
	
	/**
	 Cancels all current loadings (page and sync).
	 
	 - Returns: `true` if loader was loading when the method was called. */
	@discardableResult
	public func cancelAllLoadings() -> Bool {
		let wasLoadingPage = cancelCurrentPageLoading()
		let wasSyncing = cancelCurrentSync()
		return wasLoadingPage || wasSyncing
	}
	
	/* ***************
	   MARK: - Private
	   *************** */
	
	private struct PageLoadDescription {
		
		let isFirstPage: Bool
		
		let checkHasMore: Bool
		let checkPreviousPageInfo: Bool
		
		let pageOffsets: (start: Int, end: Int)?
		let pageInfo: CollectionLoaderHelper.PageInfo
		
		init(forFirstPageWithHelper helper: CollectionLoaderHelper, numberOfElementsPerPage: Int) {
			isFirstPage = true
			
			checkHasMore = true
			checkPreviousPageInfo = true
			
			pageOffsets = (start: 0, end: numberOfElementsPerPage)
			pageInfo = helper.pageInfoFor(startOffset: 0, endOffset: numberOfElementsPerPage)
		}
		
		init(forNextPageWithHelper helper: CollectionLoaderHelper, nextPageInfo: (offsets: (start: Int, end: Int)?, pageInfo: CollectionLoaderHelper.PageInfo)) {
			isFirstPage = false
			
			checkHasMore = true
			checkPreviousPageInfo = false
			
			pageOffsets = nextPageInfo.offsets
			pageInfo = nextPageInfo.pageInfo
		}
		
		init(forPreviousPageWithHelper helper: CollectionLoaderHelper, previousPageInfo: CollectionLoaderHelper.PageInfo) {
			isFirstPage = false
			
			checkHasMore = false
			checkPreviousPageInfo = true
			
			pageOffsets = nil
			pageInfo = previousPageInfo
		}
		
	}
	
	private let kvObserver = KVObserver()
	
	private lazy var pageLoadingQueue: OperationQueue = {
		let result = OperationQueue()
		result.maxConcurrentOperationCount = 1 /* Serial queue. */
		result.name = "Collection Loader Page Loading Queue for \(Unmanaged.passUnretained(self).toOpaque())"
		_ = kvObserver.observe(object: result, keyPath: #keyPath(OperationQueue.operationCount), kvoOptions: [.new], dispatchType: .directOrAsyncOnMainQueue) { [weak self] change in
			guard let strongSelf = self else {return}
			guard let newValue = change?[.newKey] as? Int else {return}
			
			let wasLoading = strongSelf.isLoadingPage
			let isLoading = newValue > 0
			
			let wasLoadingFirstPage = strongSelf.isLoadingFirstPage
			let isLoadingFirstPage = isLoading && (strongSelf.endOperationCheck?.pageLoadDescription.isFirstPage ?? false)
			
			let haveHadMore = strongSelf.endOperationCheck?.hadMore
			
			let endOperationResult = strongSelf.endOperationCheck.flatMap{ strongSelf.helper.results(fromFinishedLoadingOperation: $0.checkedOperation) }
			
			if let endOperationCheck = strongSelf.endOperationCheck, let results = endOperationResult?.successValue {
				if endOperationCheck.pageLoadDescription.checkPreviousPageInfo {
					strongSelf.previousPageInfo = strongSelf.helper.previousPageInfo(for: results, from: endOperationCheck.pageLoadDescription.pageInfo, nElementsPerPage: strongSelf.numberOfElementsPerPage)
				}
				if let nextPageInfo = strongSelf.helper.nextPageInfo(for: results, from: endOperationCheck.pageLoadDescription.pageInfo, nElementsPerPage: strongSelf.numberOfElementsPerPage) {
					strongSelf.nextPageInfo = nextPageInfo.flatMap{ (offsets: nil, pageInfo: $0) }
				} else if let currentPageOffsets = endOperationCheck.pageLoadDescription.pageOffsets, (haveHadMore ?? true) {
					let nextOffsets = (start: currentPageOffsets.start + strongSelf.numberOfElementsPerPage, end: currentPageOffsets.end + strongSelf.numberOfElementsPerPage)
					strongSelf.nextPageInfo = (offsets: nextOffsets, pageInfo: strongSelf.helper.pageInfoFor(startOffset: nextOffsets.start, endOffset: nextOffsets.end))
				} else {
					strongSelf.nextPageInfo = nil
				}
			}
			
			if !isLoading {
#if !NO_HAPPSIGHT
				if endOperationResult?.successValue != nil {strongSelf.lastLoadedPageNumber = strongSelf.nextPage; strongSelf.nextPage += 1}
#endif
				if let endOperationResult = endOperationResult {strongSelf.lastLoadError = endOperationResult.failure}
				strongSelf.endOperationCheck = nil
			}
			
			strongSelf.isLoadingPage = isLoading
			strongSelf.isLoadingFirstPage = isLoadingFirstPage
			if let hasMore = haveHadMore {strongSelf.hasMore = hasMore}
			
			if !wasLoading &&  strongSelf.isLoadingPage {strongSelf.didStartLoadingPageHandler?()}
			if  wasLoading && !strongSelf.isLoadingPage {strongSelf.didFinishLoadingPageHandler?(endOperationResult)}
			if  wasLoading !=  strongSelf.isLoadingPage {strongSelf.isLoadingPageChangedHandler?(); strongSelf.isLoadingPageChangedHandler2?()}
			if wasLoadingFirstPage != strongSelf.isLoadingFirstPage {strongSelf.isLoadingFirstPageChangedHandler?()}
		}
		return result
	}()
	private lazy var syncQueue: OperationQueue = {
		let result = OperationQueue()
		result.maxConcurrentOperationCount = 1 /* Serial queue */
		result.name = "Collection Loader Sync Loading Queue for \(Unmanaged.passUnretained(self).toOpaque())"
		return result
	}()
	
	private var previousPageInfo: CollectionLoaderHelper.PageInfo?
	private var nextPageInfo: (offsets: (start: Int, end: Int)?, pageInfo: CollectionLoaderHelper.PageInfo)?
	
	private var endOperationCheck: (checkedOperation: CollectionLoaderHelper.LoadingOperation, hadMore: Bool?, pageLoadDescription: PageLoadDescription)?
	
	@discardableResult
	private func load(pageLoadDescription: PageLoadDescription, force: Bool = false) -> Bool {
		assert(Thread.isMainThread)
		
		let wasLoading = isLoadingPage
		if isLoadingPage {guard force else {return false}}
		endOperationCheck = nil
		pageLoadingQueue.cancelAllOperations()
		
		if pageLoadDescription.isFirstPage {
			/* If we’re loading the first page, we’ll be destroying everything not in the first page after loading.
			 * No need to sync, it will fail. */
			syncQueue.cancelAllOperations()
		}
		
		let preImportHandler: (() -> Bool)?
		let preCompletionHandler: ((_ preresults: CollectionLoaderHelper.PreCompletionResults) throws -> Void)?
		if pageLoadDescription.isFirstPage || pageLoadDescription.checkHasMore {
			var cachedObjectIds = Set<CollectionLoaderHelper.FetchedObjectID>()
			if pageLoadDescription.isFirstPage {
				/* If we’re loading the first page, this means we'll have to clear the other loaded objects once fetching the first page has finished.
				 * Let’s setup the handlers to do that (first here, the other is the preCompletion handler). */
				preImportHandler = {
					/* Before importing the results of the operation, we retrieve the object ids of the already loaded (cached) objects. */
					for i in 0..<self.helper.numberOfCachedObjects {
						cachedObjectIds.insert(self.helper.unsafeCachedObjectId(at: i))
					}
					return true
				}
			} else {
				preImportHandler = nil
			}
			preCompletionHandler = { preresults in
				if pageLoadDescription.isFirstPage {
					/* Now the loading is over and the loaded objects have been imported in the cache.
					 * Let’s remove the objects which were not loaded in the page but were already in the cache before. */
					var loadedObjectIds = Set<CollectionLoaderHelper.FetchedObjectID>()
					for i in 0..<self.helper.numberOfFetchedObjects(for: preresults) {
						loadedObjectIds.insert(self.helper.unsafeFetchedObjectId(at: i, for: preresults))
					}
					let objectIdsToDelete = cachedObjectIds.subtracting(loadedObjectIds)
					objectIdsToDelete.forEach{ objectId in
						if self.canDeleteObjectIdHandler?(objectId) ?? true {self.helper.unsafeRemove(objectId: objectId, hardDelete: false)}
					}
				}
				
				if pageLoadDescription.checkHasMore && self.endOperationCheck != nil {
					switch self.lastPageDetectionMethod {
						case .retrievedIncompletePage:           self.endOperationCheck?.hadMore = self.helper.numberOfFetchedObjects(for: preresults) >= self.numberOfElementsPerPage
						case .retrievedLessOrExactly(let limit): self.endOperationCheck?.hadMore = self.helper.numberOfFetchedObjects(for: preresults) >  limit
						case .custom(let handler):               self.endOperationCheck?.hadMore = handler(preresults)
					}
				}
				
				try self.willFinishLoadingPageHandler?(preresults, pageLoadDescription.pageInfo, pageLoadDescription.pageOffsets)
			}
		} else if willFinishLoadingPageHandler != nil {
			preImportHandler = nil
			preCompletionHandler = { preresults in
				try self.willFinishLoadingPageHandler?(preresults, pageLoadDescription.pageInfo, pageLoadDescription.pageOffsets)
			}
		} else {
			preImportHandler = nil
			preCompletionHandler = nil
		}
		
		let operation = helper.operationForLoading(pageInfo: pageLoadDescription.pageInfo, preRun: nil, preImport: preImportHandler, preCompletion: preCompletionHandler)
		endOperationCheck = (checkedOperation: operation, hadMore: nil, pageLoadDescription: pageLoadDescription)
		pageLoadingQueue.addOperation(operation)
		return !wasLoading
	}
	
}
