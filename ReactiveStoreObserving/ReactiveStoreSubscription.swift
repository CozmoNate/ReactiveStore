//
//  ReactiveStoreSubscription.swift
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
import ReactiveStore

public let ReactiveStoreDidChangeNotification = Notification.Name("ReactiveStoreDidChange")
public let ReactiveStoreKeyPathsKey = "keyPaths"

public extension ReactiveStore {

    /// Notify observers about changed properties.
    func notify(keyPathsChanged: Set<PartialKeyPath<Self>>) {
        NotificationCenter.default.post(
            name: ReactiveStoreDidChangeNotification,
            object: self,
            userInfo: [ReactiveStoreKeyPathsKey: keyPathsChanged]
        )
    }
    
    /// Adds an observer that will be invoked each time the store changes.
    /// - Parameter queue: The queue to schedule change handler on.
    /// - Parameter changeHandler: The closure will be invoked each time the store changes.
    func addObserver(queue: OperationQueue = .main,
                     handler: @escaping (Self, Set<PartialKeyPath<Self>>) -> Void) -> ReactiveStoreSubscription {
        defer { handler(self, [\Self.self]) }
        return ReactiveStoreSubscription(store: self, queue: queue, handler: handler)
    }
    
    /// Adds an observer that will be invoked each time the store changes.
    /// - Parameter keyPaths: The list of KeyPaths describing the fields in the store that should trigger the change handler upon mutation.
    /// - Parameter queue: The queue to schedule change handler on
    /// - Parameter handler: The closure will be invoked each time the store changes fields included in observingKeyPaths param.
    func addObserver(for keyPaths: [PartialKeyPath<Self>],
                     queue: OperationQueue = .main,
                     handler: @escaping (Self) -> Void) -> ReactiveStoreSubscription {
        defer { handler(self) }
        return ReactiveStoreSubscription(store: self, queue: queue) { state, changedKeyPaths in
            if !changedKeyPaths.isDisjoint(with: keyPaths) {
                handler(self)
            }
        }
    }
}

public class ReactiveStoreSubscription {
    
    internal let observer: NSObjectProtocol
    
    internal init<Store: ReactiveStore>(store: Store, queue: OperationQueue, handler: @escaping (Store, Set<PartialKeyPath<Store>>) -> Void) {
        observer = NotificationCenter.default.addObserver(forName: ReactiveStoreDidChangeNotification, object: store, queue: queue) { notification in
            guard let store = notification.object as? Store else {
                return
            }
            guard let keyPaths = notification.userInfo?[ReactiveStoreKeyPathsKey] as? Set<PartialKeyPath<Store>> else {
                return
            }
            handler(store, keyPaths)
        }
    }
    
    /// Cancels current subscription and stops receiving updates.
    public func cancel() {
        NotificationCenter.default.removeObserver(observer)
    }
    
    /// Stores subscription in the array.
    public func store(in subscriptions: inout [ReactiveStoreSubscription]) {
        subscriptions.append(self)
    }
    
    deinit {
        cancel()
    }
}
