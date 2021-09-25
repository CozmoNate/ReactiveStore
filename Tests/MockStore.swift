//
//  Created by Natan Zalkin on 17/08/2020.
//  Copyright © 2020 Natan Zalkin. All rights reserved.
//

import Foundation

@testable import Dispatcher
@testable import ReactiveStore

class MockStore: Dispatcher, ReactiveStore {
    
    struct Actions {
        
        struct Change: Action {
            let value: String
            
            func execute(with store: MockStore, completion: @escaping () -> Void) {
                defer { completion() }
                store.lastQueueIdentifier = DispatchQueue.getSpecific(key: DispatcherQueueIdentifierKey)
                store.value = value
                store.notify(keyPathsChanged: [\MockStore.value])
            }
        }
        
        struct AsyncChange: Action {
            let value: String
            
            func execute(with store: MockStore, completion: @escaping () -> Void) {
                OperationQueue.current?.underlyingQueue?.asyncAfter(deadline: .now() + .milliseconds(250)) {
                    store.value = value
                    store.notify(keyPathsChanged: [\MockStore.value])
                    completion()
                }
            }
        }
        
        struct Update: Action {
            let number: Int
            
            func execute(with store: MockStore, completion: @escaping () -> Void) {
                defer { completion() }
                store.number = number
                store.notify(keyPathsChanged: [\MockStore.number])
            }
        }
    }
    
    private(set) var value = "initial"
    private(set) var number = 0
    
    var lastQueueIdentifier: UUID!
    
    var pipeline = Pipeline()
    var middlewares = [MockMiddleware()] as Array<Middleware>
    var isDispatching = false
}
