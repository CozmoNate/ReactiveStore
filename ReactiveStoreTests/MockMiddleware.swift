//
//  MockMiddleware.swift
//  ReactiveStoreTests
//
//  Created by Natan Zalkin on 21/10/2020.
//  Copyright © 2020 Natan Zalkin. All rights reserved.
//

import Foundation

@testable import ReactiveStore

class MockMiddleware: InterceptingMiddleware {
    
    var shouldExecute = true
    var lastExecutedStore: Any?
    var lastExecutedAction: Any?
    var lastAskedAction: Any?
    var lastAskedStore: Any?
    
    func store<Store, Action>(_ store: Store, shouldExecute action: Action) -> Bool {
        lastAskedStore = store
        lastAskedAction = action
        return shouldExecute
    }
    
    func store<Store, Action>(_ store: Store, didExecute action: Action) {
        lastExecutedStore = store
        lastExecutedAction = action
    }
}
