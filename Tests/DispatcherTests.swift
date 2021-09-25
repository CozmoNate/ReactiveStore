//
//  Created by Natan Zalkin on 15/08/2020.
//  Copyright © 2020 Natan Zalkin. All rights reserved.
//

import Quick
import Nimble

@testable import Dispatcher
@testable import ReactiveObject

extension Pipeline {
    
    var count: Int {
        guard var item = head else {
            return 0
        }
        var count = 1
        while let next = item.next {
            count += 1
            item = next
        }
        return count
    }
    
}

class DispatcherTests: QuickSpec {
    override func spec() {
        describe("Dispatcher") {
            var subject: MockStore!
            
            beforeEach {
                subject = MockStore()
            }
            
            context("when executing synchronous action") {
                
                beforeEach {
                    subject.execute(MockStore.Actions.Change(value: "sync test"), completion: {})
                }
                
                it("can handles the action and correctly changes the state") {
                    expect(subject.value).to(equal("sync test"))
                }
            }
            
            context("when executing asynchronous action") {
                beforeEach {
                    subject.execute(MockStore.Actions.AsyncChange(value: "sync test"), completion: {})
                }
                
                it("can handles the action and correctly changes the state") {
                    expect(subject.pipeline.isEmpty).to(beTrue())
                    expect(subject.value).to(equal("initial"))
                    expect(subject.value).toEventually(equal("sync test"))
                }
            }
            
            context("when dispatching actions") {
                beforeEach {
                    subject.dispatch(MockStore.Actions.AsyncChange(value: "async test"))
                    subject.dispatch(MockStore.Actions.AsyncChange(value: "async test after"))
                    subject.dispatch(MockStore.Actions.Change(value: "async test finish"))
                }
                
                it("can handles the action and correctly changes the state") {
                    expect(subject.isDispatching).to(beTrue())
                    expect(subject.pipeline.count).to(equal(2))
                    expect(subject.value).to(equal("initial"))
                    expect(subject.value).toEventually(equal("async test finish"))
                    expect(subject.isDispatching).to(beFalse())
                    expect(subject.pipeline.isEmpty).to(beTrue())
                }
            }
            
            context("when subscribed to changes and executed action") {
                var subscriptions: [ReactiveObjectSubscription]!
                var keyPaths: Set<PartialKeyPath<MockStore>>?
                
                beforeEach {
                    subscriptions = []
                    subject.addObserver { (store, paths) in
                        keyPaths = paths
                    }.store(in: &subscriptions)
                    subject.execute(MockStore.Actions.AsyncChange(value: "test subscribe"), completion: {})
                }
                
                it("notifies subscribers") {
                    expect(keyPaths).toEventually(equal(Set([\MockStore.value])))
                    expect(subject.value).toEventually(equal("test subscribe"))
                }
                
                context("when canceled subscription and executed action") {
                    beforeEach {
                        subscriptions.forEach { $0.cancel() }
                        keyPaths = nil
                        subject.execute(MockStore.Actions.Change(value: "test unsubscribe"), completion: {})
                    }
                    
                    it("does not notify subscribers") {
                        expect(keyPaths).to(beNil())
                        expect(subject.value).to(equal("test unsubscribe"))
                    }
                }
            }
            
            context("when subscribed to SPECIFIC changes and executed action") {
                var subscriptions: [ReactiveObjectSubscription]!
                var changed: Bool?
                
                beforeEach {
                    subscriptions = []
                    subject.addObserver(for: [\MockStore.value]) { (store) in
                        changed = true
                    }.store(in: &subscriptions)
                    subject.execute(MockStore.Actions.AsyncChange(value: "test subscribe"), completion: {})
                }
                
                it("notifies subscribers") {
                    expect(changed).toEventually(beTruthy())
                    expect(subject.value).toEventually(equal("test subscribe"))
                }
                
                context("when canceled subscription and executed action") {
                    beforeEach {
                        subscriptions.forEach { $0.cancel() }
                        changed = nil
                        subject.execute(MockStore.Actions.Change(value: "test unsubscribe"), completion: {})
                    }
                    
                    it("does not notify subscribers") {
                        expect(changed).to(beNil())
                        expect(subject.value).to(equal("test unsubscribe"))
                    }
                }
            }
            
            describe("Dispatch") {

                var queue: DispatchQueue!

                beforeEach {
                    queue = DispatchQueue(label: "Test", qos: .background)
                }
                
                context("when dispatched action on queue") {

                    beforeEach {
                        subject.dispatch(MockStore.Actions.Change(value: "queue test"), on: queue)
                    }

                    it("performs action") {
                        expect(subject.value).toEventually(equal("queue test"))
                        expect(subject.lastQueueIdentifier).toEventually(equal(queue.getSpecific(key: DispatcherQueueIdentifierKey)))
                    }
                }
                
                context("when dispatched action from another queue") {

                    beforeEach {
                        DispatchQueue.main.async {
                            subject.dispatch(MockStore.Actions.Change(value: "another queue test"), on: queue)
                        }
                    }

                    it("performs action") {
                        expect(subject.value).toEventually(equal("another queue test"))
                        expect(subject.lastQueueIdentifier).toEventually(equal(queue.getSpecific(key: DispatcherQueueIdentifierKey)))
                    }
                }
            }
        }
    }
}
