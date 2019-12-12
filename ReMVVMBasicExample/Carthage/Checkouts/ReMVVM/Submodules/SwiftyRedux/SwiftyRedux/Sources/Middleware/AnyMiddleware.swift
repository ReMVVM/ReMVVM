//
//  AnyMiddleware.swift
//  SwiftyRedux
//
//  Created by Dariusz Grzeszczak on 11/12/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/// Describes middleware mechanism and works on any StoreActon. Middleware enchances action's dispatch functionality and may be applied in the store during initialization process. Before action is reduced in the store's reducer it has to go through all middlewares in the stack and theirs onNext() method has to be called. Middleware may intercept action to the next middleware in the stack. Action will be reduced in the store only when it reaches all middlewares in the stack. Middleware may 'block' action's dispatch by not intercepting it to next middleware. Middleware also may dispatch completely new action. New action will go through whole middleware stack.
public protocol AnyMiddleware {

    /// Method will be called during dispatch process.
    /// - Parameters:
    ///   - state: current state in the store
    ///   - action: action that is dispatched
    ///   - interceptor: allows to intercept action to next middleware by calling next() method. Not calling next()  method blocks action's dispatch process.
    ///   - dispatcher: allows to send completely new action. New action will goo through whole middleware stack.
    func onNext<State: StoreState>(for state: State, action: StoreAction, interceptor: Interceptor<StoreAction, State>, dispatcher: Dispatcher)
}
