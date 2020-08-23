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
    /// **Important** You must call *done* closure in your action handler block, to notify the store that the action is finished executing.
    typealias ActionHandler<Action> = (_ store: Self, _ action: Action, _ done: @escaping () -> Void) -> Void
    
    /// The list of type-erased closures associated with specific action types.
    var actionHandlers: [ObjectIdentifier: Any] { get set }
    
    /// The queue of postponed actions.
    var actionQueue: ReactiveStoreQueue { get }
    
    /// The flag indicating if the store dispatches an action at the moment.
    var isDispatching: Bool { get set }
    
}

public extension ReactiveStore {
    
    /// Associates a handler with actions of the specified type.
    /// - Parameter action: The type of the actions to associate with the handler.
    /// - Parameter execute: The handler closure that will be invoked when the action received.
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
    
    /// Executes the action immediately.
    /// **Important** It is not recommended to execute actions directly. Use dispatch() method instead.
    /// - Parameter action: The action to execute.
    func execute<Action>(_ action: Action, completion: @escaping () -> Void) {
        guard let handle = self.actionHandlers[ObjectIdentifier(Action.self)] as? ActionHandler<Action> else {
            completion()
            return
        }
        
        handle(self, action, completion)
    }
    
    /// Executes the action immediately or postpones the action if another async action is executing at the moment.
    /// If dispatched while an async action is executing, the action will be send to backlog.
    /// Actions from backlog are executed serially in FIFO order, right after the previous action finishes dispatching.
    func dispatch<Action>(_ action: Action, completion: (() -> Void)? = nil) {
        let actionBlock: () -> Void = { [weak self] in
            self?.isDispatching = true
            self?.execute(action) {
                if let backlogAction = self?.actionQueue.dequeue() {
                    backlogAction()
                } else {
                    self?.isDispatching = false
                }
                completion?()
            }
        }

        if isDispatching {
            actionQueue.enqueue(actionBlock)
            return
        }
        
        if let backlogAction = actionQueue.dequeue() {
            actionQueue.enqueue(actionBlock)
            backlogAction()
            return
        }
        
        actionBlock()
    }
}

public class ReactiveStoreQueue {
    public typealias Action = () -> Void
    
    internal class Item {
        let action: Action
        var next: Item?
        
        init(_ action: @escaping Action) {
            self.action = action
        }
    }

    public var isEmpty: Bool {
        return head == nil
    }
    
    internal var head: Item? {
        didSet { if head == nil { tail = nil } }
    }
    
    internal var tail: Item?
    
    public init() {}
    
    public func enqueue(_ action: @escaping Action) {
        let item = Item(action)
        if let last = tail {
            last.next = item
            tail = item
        } else {
            head = item
            tail = head
        }
    }
    
    public func dequeue() -> Action? {
        guard let first = head else {
            return nil
        }
        head = first.next
        return first.action
    }
}
