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



final class HandlerLoadingOperationDelegate<PreCompletionResults> : LoadingOperationDelegate {
	
	let willStart: (() throws -> Void) throws -> Void
	let willImport: (() throws -> Void) throws -> Bool
	let didFinishImport: (PreCompletionResults, () throws -> Void) throws -> Void
	
	init(
		willStart: @escaping (() throws -> Void) throws -> Void = { _ in },
		willImport: @escaping (() throws -> Void) throws -> Bool = { _ in true },
		didFinishImport: @escaping (PreCompletionResults, () throws -> Void) throws -> Void = { _, _ in }
	) {
		self.willStart = willStart
		self.willImport = willImport
		self.didFinishImport = didFinishImport
	}
	
	func onContext_remoteOperationWillStart(cancellationCheck throwIfCancelled: () throws -> Void) throws {
		try willStart(throwIfCancelled)
	}
	
	func onContext_operationWillImportResults(cancellationCheck throwIfCancelled: () throws -> Void) throws -> Bool {
		return try willImport(throwIfCancelled)
	}
	
	func onContext_operationDidFinishImport(results: PreCompletionResults, cancellationCheck throwIfCancelled: () throws -> Void) throws {
		try didFinishImport(results, throwIfCancelled)
	}
	
}
