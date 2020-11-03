//
//  MockMiddleware.swift
//  ReactiveStoreTests
//
//  Created by Natan Zalkin on 21/10/2020.
//  Copyright © 2020 Natan Zalkin. All rights reserved.
//

import Foundation

@testable import ReactiveStore

class MockMiddleware: Middleware {
    
    var shouldExecute = true
    var lastExecutedStore: Store?
    var lastExecutedAction: Any?
    var lastAskedAction: Any?
    var lastAskedStore: Store?
    
    func store<Store, Action: ReactiveStore.Action>(_ store: Store, shouldExecute action: Action) -> Bool where Action.Store == Store {
        lastAskedStore = store
        lastAskedAction = action
        return shouldExecute
    }
    
    func store<Store, Action: ReactiveStore.Action>(_ store: Store, didExecute action: Action) where Action.Store == Store {
        lastExecutedStore = store
        lastExecutedAction = action
    }
}
