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

import CoreData
import Foundation

import BMO
import BMOCoreData

import CollectionLoader



public struct BMOCoreDataSearchLoader<Bridge : BridgeProtocol, FetchedObject : NSManagedObject, PageInfo : PageInfoProtocol> : CollectionLoaderHelperProtocol
where Bridge.LocalDb.DbObject == NSManagedObject/* and NOT FetchedObject */, Bridge.LocalDb.DbContext == NSManagedObjectContext {
	
	public typealias LoadingOperation = Bridge.RemoteDb.RemoteOperation
	
	public typealias CompletionResults = LocalDbChanges<NSManagedObject, Bridge.Metadata>
	public typealias PreCompletionResults = LocalDbChanges<NSManagedObject, Bridge.Metadata>
	
	public var bridge: Bridge
	public let resultsController: NSFetchedResultsController<FetchedObject>
	
	public var context: NSManagedObjectContext {
		resultsController.managedObjectContext
	}
	
	init(
		bridge: Bridge,
		context: NSManagedObjectContext,
		fetchRequest: NSFetchRequest<FetchedObject>,
		apiOrderProperty: NSAttributeDescription? = nil,
		apiOrderDelta: Int = 1,
		deletionDateProperty: NSAttributeDescription? = nil,
		fetchRequestToBridgeRequest: (NSFetchRequest<FetchedObject>) -> Bridge.LocalDb.DbRequest
	) throws {
		assert(apiOrderDelta > 0)
		assert(deletionDateProperty.flatMap{ ["NSDate", "Date"].contains($0.attributeValueClassName) } ?? true)
		
		let controllerFetchRequest = fetchRequest.copy() as! NSFetchRequest<FetchedObject> /* We must copy because of ObjC legacy. */
		if let apiOrderProperty {
			controllerFetchRequest.sortDescriptors = [NSSortDescriptor(key: apiOrderProperty.name, ascending: true)] + (controllerFetchRequest.sortDescriptors ?? [])
		}
		if let deletionDateProperty {
			let deletionPredicate = NSPredicate(format: "%K == NULL", deletionDateProperty.name)
			if let currentPredicate = controllerFetchRequest.predicate {controllerFetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [currentPredicate, deletionPredicate])}
			else                                                       {controllerFetchRequest.predicate = deletionPredicate}
		}
		
		self.bridge = bridge
		self.localDbRequest = fetchRequestToBridgeRequest(fetchRequest)
		self.resultsController = NSFetchedResultsController<FetchedObject>(fetchRequest: controllerFetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
		
		self.apiOrderDelta = apiOrderDelta
		self.apiOrderProperty = apiOrderProperty
		self.deletionDateProperty = deletionDateProperty
		
		try resultsController.performFetch()
	}
	
	/* *************************
	   MARK: Get Current Objects
	   ************************* */
	
	public func onContext_numberOfObjects() -> Int {
		return 0
	}
	
	public func onContext_object(at index: Int) -> FetchedObject {
		preconditionFailure()
	}
	
	/* *********************************************
	   MARK: Get Objects from Pre-Completion Results
	   ********************************************* */
	
	public func onContext_numberOfObjects(from preCompletionResults: PreCompletionResults) -> Int {
		return 0
	}
	
	public func onContext_object(at index: Int, from preCompletionResults: PreCompletionResults) -> FetchedObject {
		preconditionFailure()
	}
	
	/* ****************
	   MARK: Load Pages
	   **************** */
	
	public func operationForLoading(pageInfo: PageInfo, delegate: any LoadingOperationDelegate<PreCompletionResults>) throws -> LoadingOperation {
		throw NotImplemented()
	}
	
	public func results(from finishedLoadingOperation: LoadingOperation) -> Result<CompletionResults, Error> {
		return .failure(NotImplemented())
	}
	
	/* *************************
	   MARK: Getting Pages Infos
	   ************************* */
	
	public func initialPageInfo() -> PageInfo {
		preconditionFailure()
	}
	
	public func nextPageInfo(for completionResults: CompletionResults, from pageInfo: PageInfo) -> PageInfo? {
		return nil
	}
	
	public func previousPageInfo(for completionResults: CompletionResults, from pageInfo: PageInfo) -> PageInfo? {
		return nil
	}
	
	/* **********************
	   MARK: Deleting Objects
	   ********************** */
	
	public func onContext_delete(object: FetchedObject) {
	}
	
	/* ***************
	   MARK: - Private
	   *************** */
	
	private let localDbRequest: Bridge.LocalDb.DbRequest
	
	private let apiOrderProperty: NSAttributeDescription?
	private let apiOrderDelta: Int /* Must be > 0 */
	private let deletionDateProperty: NSAttributeDescription?
	
}
struct NotImplemented : Error {}
