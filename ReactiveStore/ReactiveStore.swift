//
//  ReactiveStore.swift
//
//  Copyright © 2020 Natan Zalkin. All rights reserved.
//

/*
* Copyright (c) 2020 Natan Zalkin
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
*/

import Foundation

let ReactiveStoreChangedNotification = Notification.Name("ReactiveStoreChanged")
let ReactiveStoreChangedKeyPathsKey = "changedKeyPaths"

/// ReactiveStore is an object that represents a state and performs self mutation by handling dispatched actions.
open class ReactiveStore: AnyStore {
    
    /// The flag indicating if the store is handling the action at the moment.
    internal(set) public var isExecuting: Bool = false
    
    /// The list of type-erased mutation blocks associated with specific action types.
    internal var mutators: [ObjectIdentifier: Any]
    
    /// The FIFO queue of postponed actions.
    internal var backlog: Backlog
    
    public init() {
        mutators = [:]
        backlog = Backlog()
    }
}

public extension AnyStore where Self: ReactiveStore {
    
    /// A store mutator closure. Mutator applies changes to the store and returns the list of changed fields.
    typealias Mutator<Action> = (_ store: Self, _ action: Action, _ completion: @escaping () -> Void) -> Void
    
    /// Associates a mutation with actions of the specified type.
    /// - Parameter action: The type of the actions to associate with the mutation.
    /// - Parameter execute: The mutator closure that will be invoked when the action received.
    func registerMutator<Action>(for action: Action.Type, mutator: @escaping Mutator<Action>) {
        mutators[ObjectIdentifier(Action.self)] = mutator
    }
    
    /// Unregisters mutator associated with actions of the specified type.
    /// - Parameter action: The action for which the associated mutator should be removed
    @discardableResult
    func unregisterMutator<Action>(for action: Action.Type) -> Mutator<Action>? {
        return mutators.removeValue(forKey: ObjectIdentifier(Action.self)) as? Mutator<Action>
    }
    
    /// Unregisters all mutators.
    func unregisterAllMutators() {
        mutators.removeAll()
    }
    
    /// Adds an observer that will be invoked each time the store changes.
    /// - Parameter queue: The queue to schedule change handler on.
    /// - Parameter changeHandler: The closure will be invoked each time the store changes.
    func addObserver(queue: OperationQueue = .main, handler: @escaping (Self, Set<PartialKeyPath<Self>>) -> Void) -> Subscription {
        return Subscription(store: self, queue: queue, handler: handler)
    }
    
    /// Adds an observer that will be invoked each time the store changes.
    /// - Parameter queue: The queue to schedule change handler on
    /// - Parameter keyPaths: The list of KeyPaths describing the fields in the store that should trigger the change handler upon mutation.
    /// - Parameter handler: The closure will be invoked each time the store changes fields included in observingKeyPaths param.
    func addObserver(observing keyPaths: [PartialKeyPath<Self>], queue: OperationQueue = .main, handler: @escaping (Self) -> Void) -> Subscription {
        return Subscription(store: self, queue: queue) { state, changedKeyPaths in
            if !changedKeyPaths.isDisjoint(with: keyPaths) {
                handler(self)
            }
        }
    }
    
    /// Dispatches an action to the store. All actions are executed serially in FIFO order.
    /// - Parameter action: The action to dispatch.
    func dispatch<Action>(_ action: Action) {
        if isExecuting {
            backlog.push { [weak self] in
                self?.execute(action: action)
            }
        } else if !backlog.pop() {
            isExecuting = true
            execute(action: action)
        }
    }
    
    /// Send notification about changes to observers.
    func notify(keyPathsChanged: Set<PartialKeyPath<Self>>) {
        NotificationCenter.default.post(
            name: ReactiveStoreChangedNotification,
            object: self,
            userInfo: [ReactiveStoreChangedKeyPathsKey: keyPathsChanged]
        )
    }
}

internal extension AnyStore where Self: ReactiveStore {
    
    func execute<Action>(action: Action) {
        guard let mutate = self.mutators[ObjectIdentifier(Action.self)] as? Mutator<Action> else {
            return
        }

        mutate(self, action) { [weak self] in
            guard let self = self else { return }
            self.isExecuting = false
            self.backlog.pop()
        }
    }
}
