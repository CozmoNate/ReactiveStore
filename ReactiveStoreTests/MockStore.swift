//
//  MockStore.swift
//  ReactiveStoreTests
//
//  Created by Natan Zalkin on 17/08/2020.
//  Copyright © 2020 Natan Zalkin. All rights reserved.
//

import Foundation

@testable import ReactiveStore

class MockStore: ReactiveStore {
    
    struct Action {
        struct Change {
            let value: String
        }
        
        struct AsyncChange {
            let value: String
        }
        
        struct Update {
            let number: Int
        }
    }
    
    private(set) var value = "initial"
    private(set) var number = 0
    
    var actionHandlers = [ObjectIdentifier: Any]()
    var actionQueue = ReactiveStoreQueue()

    var isDispatching = false
    
    init() {
        register(Action.Change.self) { (store, action, done) in
            store.value = action.value
            store.notify(keyPathsChanged: [\MockStore.value])
            done()
        }
        
        register(Action.AsyncChange.self) { (store, action, done) in
            OperationQueue.current?.underlyingQueue?.asyncAfter(deadline: .now() + .microseconds(250)) {
                store.value = action.value
                store.notify(keyPathsChanged: [\MockStore.value])
                done()
            }
        }
        
        register(Action.Update.self) { (store, action, done) in
            store.number = action.number
            store.notify(keyPathsChanged: [\MockStore.number])
            done()
        }
    }
}
