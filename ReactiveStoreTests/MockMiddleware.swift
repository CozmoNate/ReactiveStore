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
    
    func scheduler<Scheduler, Action>(_ scheduler: Scheduler, shouldExecute action: Action) -> Bool {
        lastAskedStore = scheduler
        lastAskedAction = action
        return shouldExecute
    }
    
    func scheduler<Scheduler, Action>(_ scheduler: Scheduler, didExecute action: Action) {
        lastExecutedStore = scheduler
        lastExecutedAction = action
    }
}
