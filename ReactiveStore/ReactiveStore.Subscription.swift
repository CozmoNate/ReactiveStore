//
//  ReactiveStore.Subscription.swift
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

public extension ReactiveStore {
    
    class Subscription {
        
        private let observer: NSObjectProtocol
        
        internal init<Store: ReactiveStore>(store: Store, queue: OperationQueue, handler: @escaping (Store, Set<PartialKeyPath<Store>>) -> Void) {
            observer = NotificationCenter.default.addObserver(forName: ReactiveStoreChangedNotification, object: store, queue: queue) { notification in
                guard let store = notification.object as? Store else {
                    return
                }
                guard let keyPaths = notification.userInfo?[ReactiveStoreChangedKeyPathsKey] as? Set<PartialKeyPath<Store>> else {
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
        public func store(in subscriptions: inout [Subscription]) {
            subscriptions.append(self)
        }
        
        deinit {
            cancel()
        }
    }
}
