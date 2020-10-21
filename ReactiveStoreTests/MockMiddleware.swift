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
    var lastExecutedStore: ReactiveStore?
    var lastExecutedAction: Any?
    var lastAskedAction: Any?
    var lastAskedStore: ReactiveStore?
    
    func store<Store, Action>(_ store: Store, shouldExecute action: Action) -> Bool where Store : ReactiveStore {
        lastAskedStore = store
        lastAskedAction = action
        return shouldExecute
    }
    
    func store<Store, Action>(_ store: Store, didExecute action: Action) where Store : ReactiveStore {
        lastExecutedStore = store
        lastExecutedAction = action
    }
}
