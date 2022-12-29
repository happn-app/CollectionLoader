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
	
	func operationLoadingDelegate<Helper : CollectionLoaderHelperProtocol>(for collectionLoader: CollectionLoader<Helper>, pageLoadDescription: PageLoadDescription, delegate: (any CollectionLoaderDelegate<Helper>)?) -> some LoadingOperationDelegate<Helper.PreCompletionResults>
	where Helper.PageInfo == PageInfo, Helper.FetchedObject == FetchedObject, Helper.PageInfo == PageInfo {
		return HandlerLoadingOperationDelegate<Helper.PreCompletionResults>(
			willStart: { _ in
				return true
			},
			willImport: { _ in
				return true
			},
			didFinishImport: { [weak collectionLoader] results, isOperationCancelled in
				guard let collectionLoader else {return}
				try collectionLoader.callWillFinishLoading(on: delegate, pageLoadDescription: pageLoadDescription, results: results, isOperationCancelled: isOperationCancelled)
			}
		)
	}
	
}
