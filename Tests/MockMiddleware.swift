//
//  Created by Natan Zalkin on 21/10/2020.
//  Copyright © 2020 Natan Zalkin. All rights reserved.
//

import Foundation

@testable import Dispatcher

class MockMiddleware: Middleware {
    
    var shouldExecute = true
    var lastExecutedDispatcher: Any?
    var lastExecutedAction: Any?
    var lastAskedAction: Any?
    var lastAskedStore: Any?
    
    func dispatcher<Dispatcher, Action>(_ dispatcher: Dispatcher, shouldExecute action: Action) -> Bool {
        lastAskedStore = dispatcher
        lastAskedAction = action
        return shouldExecute
    }
    
    func dispatcher<Dispatcher, Action>(_ dispatcher: Dispatcher, didExecute action: Action) {
        lastExecutedDispatcher = dispatcher
        lastExecutedAction = action
    }
}
