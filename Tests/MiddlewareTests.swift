//
//  Created by Natan Zalkin on 21/10/2020.
//  Copyright © 2020 Natan Zalkin. All rights reserved.
//

import Quick
import Nimble

@testable import Dispatcher

class MiddlewareTests: QuickSpec {
    override func spec() {
        describe("Middleware") {
            
            var store: MockStore!
            var subject: MockMiddleware!
            
            beforeEach {
                store = MockStore()
                subject = store.middlewares[0] as? MockMiddleware
            }
            
            context("when dispatched an action") {
                
                beforeEach {
                    subject.shouldExecute = false
                    store.dispatch(MockStore.Actions.Change(value: "test"))
                }
            
                it("can stop action execution") {
                    expect(subject.lastAskedAction).to(beAKindOf(MockStore.Actions.Change.self))
                    expect(subject.lastExecutedAction).to(beNil())
                }
            }
        }
    }
}
