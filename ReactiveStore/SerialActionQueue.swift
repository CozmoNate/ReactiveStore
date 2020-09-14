//
//  SerialActionQueue.swift
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

public class SerialActionQueue {
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
    
    public func clear() {
        head = nil
    }
}
