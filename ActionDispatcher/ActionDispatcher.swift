//
//  ActionDispatcher.swift
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

/// ActionDispatcher is an object allowing to dispatch actions and provides infrastructure for action to perform job
public protocol ActionDispatcher: AnyObject {

    /// The queue of postponed actions
    var actionQueue: ActionQueue { get set }
    
    /// The list of objects that are conforming to Middleware protocol and receive events when the action is executed
    var middlewares: [InterceptingMiddleware] { get set }
    
    /// The flag indicating if an action is being dispatched right now
    var isDispatching: Bool { get set }
}

public extension ActionDispatcher {
    
    /// Executes the action immediately or postpones the action if another async action is executing at the moment.
    /// If dispatched while an async action is executing, the action will be send to the queue.
    /// Actions from queue are executed serially in FIFO order, right after the previous action finishes dispatching.
    /// - Parameters:
    ///   - action: The type of the actions to associate with the handler.
    //    - completion: The block that will be invoked right after the action is finished executing.
    func dispatch<Action: ExecutableAction>(_ action: Action, completion: (() -> Void)? = nil) where Action.Dispatcher == Self {
        let actionBlock: () -> Void = { [weak self] in
            self?.execute(action) {
                completion?()
                self?.flush()
            }
        }
        if isDispatching {
            actionQueue.enqueue(actionBlock)
        } else {
            isDispatching = true
            actionBlock()
        }
    }
}

public extension ActionDispatcher {
    
    /// Unconditionally executes the action on current queue. NOTE: It is not recommended to execute actions directly.
    /// Use "execute" to apply an action immediately inside async "dispatched" action without locking the queue.
    ///
    /// - Parameter action: The action to execute.
    func execute<Action: ExecutableAction>(_ action: Action, completion: (() -> Void)? = nil) where Action.Dispatcher == Self {
        let shouldExecute = middlewares.reduce(into: true) { (result, middleware) in
            guard result else { return }
            result = middleware.store(self, shouldExecute: action)
        }
        
        guard shouldExecute else {
            completion?()
            return
        }
        
        action.execute(with: self) {
            self.middlewares.forEach { $0.store(self, didExecute: action) }
            completion?()
        }
    }
    
    /// Asynchronously dispatches the action on specified queue using barrier flag (serially). If already running on the specified queue, dispatches the action synchronously.
    /// - Parameters:
    ///   - action: The action to dispatch.
    ///   - queue: The queue to dispatch action on.
    //    - completion: The block that will be invoked right after the action is finished executing.
    func dispatch<Action: ExecutableAction>(_ action: Action, on queue: DispatchQueue, completion: (() -> Void)? = nil) where Action.Dispatcher == Self {
        if DispatchQueue.isRunning(on: queue) {
            dispatch(action, completion: completion)
        } else {
            queue.async(flags: .barrier) {
                self.dispatch(action, completion: completion)
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

internal extension ActionDispatcher {

    /// Executes the actions from the queue.
    func flush() {
        if let nextAction = actionQueue.dequeue() {
            nextAction()
        } else {
            isDispatching = false
        }
    }
}
