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

/// ReactiveStore is an object that represents a state and performs self mutation by handling dispatched actions.
public protocol ReactiveStore: AnyObject {
    
    /// A store handler closure. Handler applies changes to the store and returns the list of changed fields.
    /// **Important** You must call *completion* closure in your action handler block to notify the store that the action is finished executing.
    typealias ActionHandler<Action> = (_ store: Self, _ action: Action, _ completion: @escaping () -> Void) -> Void
    
    /// The list of type-erased closures associated with specific action types.
    var actionHandlers: [ObjectIdentifier: Any] { get set }
    
    /// The queue of postponed actions.
    var actionQueue: SerialActionQueue { get }
    
    /// The flag indicating if the store dispatches an action at the moment.
    var isDispatching: Bool { get set }
    
}

public extension ReactiveStore {
    
    /// Associates a handler with actions of the specified type.
    /// - Parameters:
    ///   - action: The type of the actions to associate with the handler.
    ///   - execute: The handler closure that will be invoked when the action received.
    func register<Action>(_ action: Action.Type, handler: @escaping ActionHandler<Action>) {
        actionHandlers.updateValue(handler, forKey: ObjectIdentifier(Action.self))
    }
    
    /// Unregisters handler associated with actions of the specified type.
    /// - Parameter action: The action for which the associated handler should be removed.
    func unregister<Action>(_ action: Action.Type) {
        actionHandlers.removeValue(forKey: ObjectIdentifier(Action.self))
    }
    
    /// Unregisters all action handlers
    func unregisterAll() {
        actionHandlers.removeAll()
    }
    
    /// Executes the action immediately or postpones the action if another async action is executing at the moment.
    /// If dispatched while an async action is executing, the action will be send to the queue.
    /// Actions from queue are executed serially in FIFO order, right after the previous action finishes dispatching.
    /// - Parameters:
    ///   - action: The type of the actions to associate with the handler.
    func dispatch<Action>(_ action: Action) {
        let actionBlock: () -> Void = { [weak self] in
            self?.execute(action) { self?.flush() }
        }
        if isDispatching {
            actionQueue.enqueue(actionBlock)
        } else {
            isDispatching = true
            actionBlock()
        }
    }
}

public extension ReactiveStore {
    
    /// Asynchronously dispatches the action on specified queue using barrier flag (serially). If already running on the specified queue, dispatches the action synchronously.
    /// - Parameters:
    ///   - action: The action to dispatch.
    ///   - queue: The queue to dispatch action on.
    func dispatch<Action>(_ action: Action, on queue: DispatchQueue) {
        if DispatchQueue.isRunning(on: queue) {
            dispatch(action)
        } else {
            queue.async(flags: .barrier) {
                self.dispatch(action)
            }
        }
    }
}

internal let ReactiveStoreQueueIdentifierKey = DispatchSpecificKey<UUID>()

internal extension DispatchQueue {
    
    static func isRunning(on queue: DispatchQueue) -> Bool {
        var identifier: UUID! = queue.getSpecific(key: ReactiveStoreQueueIdentifierKey)
        if identifier == nil {
            identifier = UUID()
            queue.setSpecific(key: ReactiveStoreQueueIdentifierKey, value: identifier)
        }
        return DispatchQueue.getSpecific(key: ReactiveStoreQueueIdentifierKey) == identifier
    }
}

internal extension ReactiveStore {
    
    /// Executes the action immediately.
    /// - Parameter action: The action to execute.
    func execute<Action>(_ action: Action, completion: @escaping () -> Void) {
        guard let handle = actionHandlers[ObjectIdentifier(Action.self)] as? ActionHandler<Action> else {
            completion()
            return
        }
        
        handle(self, action, completion)
    }
    
    /// Executes the actions from the queue.
    func flush() {
        if let nextAction = actionQueue.dequeue() {
            nextAction()
        } else {
            isDispatching = false
        }
    }
}
