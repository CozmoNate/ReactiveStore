//
//  Middleware.swift
//  ReactiveStore
//
//  Created by Natan Zalkin on 19/10/2020.
//  Copyright © 2020 Natan Zalkin. All rights reserved.
//

import Foundation

public protocol Middleware {
    
    func store<Store, Action>(_ store: Store, willExecute action: Action)
    func store<Store, Action>(_ store: Store, didExecute action: Action)
}
