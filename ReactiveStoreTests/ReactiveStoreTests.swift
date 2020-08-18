//
//  ReactiveStoreTests.swift
//  ReactiveStoreTests
//
//  Created by Natan Zalkin on 15/08/2020.
//  Copyright © 2020 Natan Zalkin. All rights reserved.
//

import Quick
import Nimble

@testable import ReactiveStore

class ReactiveStoreTests: QuickSpec {
    override func spec() {
        describe("ReactiveStore") {
            var subject: MockStore!
            
            beforeEach {
                subject = MockStore()
            }
            
            it("registered an action correctly") {
                let handler = subject.actions[ObjectIdentifier(MockStore.Action.Change.self)] as? MockStore.ActionHandler<MockStore.Action.Change>
                expect(handler).toNot(beNil())
            }
            
            context("when executing synchronous action") {
                beforeEach {
                    subject.execute(MockStore.Action.Change(value: "sync test"), completion: {})
                }
                
                it("can handles the action and correctly changes the state") {
                    expect(subject.value).to(equal("sync test"))
                }
            }
            
            context("when executing asynchronous action") {
                beforeEach {
                    subject.execute(MockStore.Action.AsyncChange(value: "sync test"), completion: {})
                }
                
                it("can handles the action and correctly changes the state") {
                    expect(subject.backlog.isEmpty).to(beTrue())
                    expect(subject.value).to(equal("initial"))
                    expect(subject.value).toEventually(equal("sync test"))
                }
            }
            
            context("when dispatching actions") {
                beforeEach {
                    subject.dispatch(MockStore.Action.AsyncChange(value: "async test"))
                    subject.dispatch(MockStore.Action.AsyncChange(value: "async test after"))
                    subject.dispatch(MockStore.Action.Change(value: "async test finish"))
                }
                
                it("can handles the action and correctly changes the state") {
                    expect(subject.isDispatching).to(beTrue())
                    expect(subject.backlog.count).to(equal(2))
                    expect(subject.value).to(equal("initial"))
                    expect(subject.value).toEventually(equal("async test finish"))
                    expect(subject.isDispatching).to(beFalse())
                    expect(subject.backlog.isEmpty).to(beTrue())
                }
            }
            
            context("when unregistered specific action") {
                beforeEach {
                    subject.unregister(MockStore.Action.Change.self)
                    subject.execute(MockStore.Action.Change(value: "test test"), completion: {})
                }
                
                it("does not handle unregistered action") {
                    expect(subject.actions.count).to(equal(2))
                    expect(subject.value).to(equal("initial"))
                }
            }
            
            context("when unregistered all actions") {
                beforeEach {
                    subject.unregisterAll()
                }
                
                it("has no registered actions") {
                    expect(subject.actions).to(beEmpty())
                }
            }
            
            context("when subscribed to changes and executed action") {
                var subscriptions: [ReactiveStoreSubscription]!
                var keyPaths: Set<PartialKeyPath<MockStore>>?
                
                beforeEach {
                    subscriptions = []
                    subject.addObserver { (store, paths) in
                        keyPaths = paths
                    }.store(in: &subscriptions)
                    subject.execute(MockStore.Action.AsyncChange(value: "test subscribe"), completion: {})
                }
                
                it("notifies subscribers") {
                    expect(keyPaths).toEventually(equal(Set([\MockStore.value])))
                    expect(subject.value).toEventually(equal("test subscribe"))
                }
                
                context("when canceled subscription and executed action") {
                    beforeEach {
                        subscriptions.forEach { $0.cancel() }
                        keyPaths = nil
                        subject.execute(MockStore.Action.Change(value: "test unsubscribe"), completion: {})
                    }
                    
                    it("does not notify subscribers") {
                        expect(keyPaths).to(beNil())
                        expect(subject.value).to(equal("test unsubscribe"))
                    }
                }
            }
            
            context("when subscribed to SPECIFIC changes and executed action") {
                var subscriptions: [ReactiveStoreSubscription]!
                var changed: Bool?
                
                beforeEach {
                    subscriptions = []
                    subject.addObserver(for: [\MockStore.value]) { (store) in
                        changed = true
                    }.store(in: &subscriptions)
                    subject.execute(MockStore.Action.AsyncChange(value: "test subscribe"), completion: {})
                }
                
                it("notifies subscribers") {
                    expect(changed).toEventually(beTruthy())
                    expect(subject.value).toEventually(equal("test subscribe"))
                }
                
                context("when canceled subscription and executed action") {
                    beforeEach {
                        subscriptions.forEach { $0.cancel() }
                        changed = nil
                        subject.execute(MockStore.Action.Change(value: "test unsubscribe"), completion: {})
                    }
                    
                    it("does not notify subscribers") {
                        expect(changed).to(beNil())
                        expect(subject.value).to(equal("test unsubscribe"))
                    }
                }
            }
        }
    }
}
