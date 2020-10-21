//
//  Middleware.swift
//  ReactiveStore
//
//  Created by Natan Zalkin on 19/10/2020.
//  Copyright © 2020 Natan Zalkin. All rights reserved.
//

import Foundation

public protocol Middleware {
    
    /// This method is called by the store before executing the action
    /// - Parameters:
    ///   - store: The store that would execute the action
    ///   - action: The action that should be executed
    func store<Store: ReactiveStore, Action>(_ store: Store, shouldExecute action: Action) -> Bool
    
    
    /// This method is called by the store after the action is executed
    /// - Parameters:
    ///   - store: The store that executed the action
    ///   - action: The action that has been executed
    func store<Store: ReactiveStore, Action>(_ store: Store, didExecute action: Action)
}
