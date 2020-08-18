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

public let ReactiveStoreDidChangeNotification = Notification.Name("ReactiveStoreDidChange")
public let ReactiveStoreKeyPathsKey = "keyPaths"

/// ReactiveStore is an object that represents a state and performs self mutation by handling dispatched actions.
public protocol ReactiveStore: AnyObject {
    
    /// A store handler closure. Handler applies changes to the store and returns the list of changed fields.
    /// **Important** You must call *done* closure in your action handler block, to notify the store that the action is finished executing.
    typealias ActionHandler<Action> = (_ store: Self, _ action: Action, _ done: @escaping () -> Void) -> Void
    
    /// The list of type-erased closures associated with specific  action types.
    var actions: [ObjectIdentifier: Any] { get set }
    
    /// The flag indicating if the store dispatches actions at the moment.
    var isDispatching: Bool { get set }
    
    /// The FIFO queue of postponed actions.
    var backlog: ReactiveStoreBacklog { get }
    
}

public extension ReactiveStore {
    
    /// Associates a handler with actions of the specified type.
    /// - Parameter action: The type of the actions to associate with the handler.
    /// - Parameter execute: The handler closure that will be invoked when the action received.
    func register<Action>(_ action: Action.Type, handler: @escaping ActionHandler<Action>) {
        actions.updateValue(handler, forKey: ObjectIdentifier(Action.self))
    }
    
    /// Unregisters handler associated with actions of the specified type.
    /// - Parameter action: The action for which the associated handler should be removed.
    func unregister<Action>(_ action: Action.Type) {
        actions.removeValue(forKey: ObjectIdentifier(Action.self))
    }
    
    /// Unregisters all actions
    func unregisterAll() {
        actions.removeAll()
    }
    
    /// Executes the action immediately.
    /// **Important** It is not recommended to execute actions directly. Use dispatch() method instead.
    /// - Parameter action: The action to execute.
    func execute<Action>(_ action: Action, completion: @escaping () -> Void) {
        guard let handle = self.actions[ObjectIdentifier(Action.self)] as? ActionHandler<Action> else {
            completion()
            return
        }
        
        handle(self, action, completion)
    }
    
    /// Notify observers about changed properties.
    func notify(keyPathsChanged: Set<PartialKeyPath<Self>>) {
        NotificationCenter.default.post(
            name: ReactiveStoreDidChangeNotification,
            object: self,
            userInfo: [ReactiveStoreKeyPathsKey: keyPathsChanged]
        )
    }
    
    /// Executes the action immediately or postpones the action if another async action is executing at the moment.
    /// If dispatched while an async action is executing, the action will be send to backlog.
    /// Actions from backlog are executed serially in FIFO order, right after the previous action finishes dispatching.
    func dispatch<Action>(_ action: Action, completion: (() -> Void)? = nil) {
        
        let actionBlock: () -> Void = { [weak self] in
            self?.isDispatching = true
            self?.execute(action) {
                if let backlogAction = self?.backlog.pop() {
                    backlogAction()
                } else {
                    self?.isDispatching = false
                }
                completion?()
            }
        }

        if isDispatching {
            backlog.push(actionBlock)
            return
        }
        
        guard let backlogAction = backlog.pop() else {
            actionBlock()
            return
        }
        
        backlog.push(actionBlock)
        
        backlogAction()
    }

    /// Adds an observer that will be invoked each time the store changes.
    /// - Parameter queue: The queue to schedule change handler on.
    /// - Parameter changeHandler: The closure will be invoked each time the store changes.
    func addObserver(queue: OperationQueue = .main,
                     handler: @escaping (Self, Set<PartialKeyPath<Self>>) -> Void) -> ReactiveStoreSubscription {
        return ReactiveStoreSubscription(store: self, queue: queue, handler: handler)
    }
    
    /// Adds an observer that will be invoked each time the store changes.
    /// - Parameter keyPaths: The list of KeyPaths describing the fields in the store that should trigger the change handler upon mutation.
    /// - Parameter queue: The queue to schedule change handler on
    /// - Parameter handler: The closure will be invoked each time the store changes fields included in observingKeyPaths param.
    func addObserver(for keyPaths: [PartialKeyPath<Self>],
                     queue: OperationQueue = .main,
                     handler: @escaping (Self) -> Void) -> ReactiveStoreSubscription {
        return ReactiveStoreSubscription(store: self, queue: queue) { state, changedKeyPaths in
            if !changedKeyPaths.isDisjoint(with: keyPaths) {
                handler(self)
            }
        }
    }
}
