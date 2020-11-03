//
//  MockStore.swift
//  ReactiveStoreTests
//
//  Created by Natan Zalkin on 17/08/2020.
//  Copyright © 2020 Natan Zalkin. All rights reserved.
//

import Foundation

@testable import ReactiveStore
@testable import ReactiveStoreObserving

class MockStore: ReactiveStore {
    
    struct Action {
        
        struct Change: ExecutableAction {
            let value: String
            
            func execute(on store: MockStore, completion: @escaping () -> Void) {
                store.lastQueueIdentifier = DispatchQueue.getSpecific(key: ReactiveStoreQueueIdentifierKey)
                store.value = value
                store.notify(keyPathsChanged: [\MockStore.value])
                completion()
            }
        }
        
        struct AsyncChange: ExecutableAction {
            let value: String
            
            func execute(on store: MockStore, completion: @escaping () -> Void) {
                OperationQueue.current?.underlyingQueue?.asyncAfter(deadline: .now() + .milliseconds(250)) {
                    store.value = value
                    store.notify(keyPathsChanged: [\MockStore.value])
                    completion()
                }
            }
        }
        
        struct Update: ExecutableAction {
            let number: Int
            
            func execute(on store: MockStore, completion: @escaping () -> Void) {
                store.number = number
                store.notify(keyPathsChanged: [\MockStore.number])
                completion()
            }
        }
    }
    
    private(set) var value = "initial"
    private(set) var number = 0
    
    var lastQueueIdentifier: UUID!
    
    var actionQueue = ActionQueue()
    var middlewares = Array<InterceptingMiddleware>([MockMiddleware()])
    var isDispatching = false
}
