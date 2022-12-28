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
	
	let willStart: () -> Bool
	let willImport: () throws -> Bool
	let didFinishImport: (PreCompletionResults) throws -> Void
	
	init(willStart: @escaping () -> Bool, willImport: @escaping () throws -> Bool, didFinishImport: @escaping (PreCompletionResults) throws -> Void) {
		self.willStart = willStart
		self.willImport = willImport
		self.didFinishImport = didFinishImport
	}
	
	func onContext_remoteOperationWillStart() -> Bool {
		return willStart()
	}
	
	func onContext_operationWillImportResults() throws -> Bool {
		return try willImport()
	}
	
	func onContext_operationDidFinishImport(results: PreCompletionResults) throws {
		try didFinishImport(results)
	}
	
}
