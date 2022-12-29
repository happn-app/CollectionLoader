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
	
	let willStart: (() -> Bool) -> Bool
	let willImport: (() -> Bool) throws -> Bool
	let didFinishImport: (PreCompletionResults, () -> Bool) throws -> Void
	
	init(willStart: @escaping (() -> Bool) -> Bool, willImport: @escaping (() -> Bool) throws -> Bool, didFinishImport: @escaping (PreCompletionResults, () -> Bool) throws -> Void) {
		self.willStart = willStart
		self.willImport = willImport
		self.didFinishImport = didFinishImport
	}
	
	func onContext_remoteOperationWillStart(isOperationCancelled: () -> Bool) -> Bool {
		return willStart(isOperationCancelled)
	}
	
	func onContext_operationWillImportResults(isOperationCancelled: () -> Bool) throws -> Bool {
		return try willImport(isOperationCancelled)
	}
	
	func onContext_operationDidFinishImport(results: PreCompletionResults, isOperationCancelled: () -> Bool) throws {
		try didFinishImport(results, isOperationCancelled)
	}
	
}
