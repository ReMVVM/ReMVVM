//
//  Interceptor.swift
//  SwiftyRedux
//
//  Created by Dariusz Grzeszczak on 11/12/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/// Intercepts call of next(action:completion:) method to the custom function. Used by Middleware to intercept the action to the next middleware in the stack.
/// May be used in UnitTests to test if middleware intercepts an action properly.
public struct Interceptor<Action, State> {

    private let _next: InterceptorNextFunction<Action, State>
    /// Initialize interceptor with custom function.
    /// - Parameter next: custom function that next() call will be intercepted to
    public init(next: @escaping InterceptorNextFunction<Action, State>) {
        self._next = next
    }

    /// Intercepts call to the custom function
    /// - Parameters:
    ///   - action: action will be intercepted
    ///   - completion: completion block used to inform the caller that action was reduced with new state in the parameter
    public func next(action: Action? = nil, completion: ((State) -> Void)? = nil) {
        _next(action, completion)
    }
}

/// Custom function that Interceptor's next(action:completion:) method will be intercepted to
public typealias InterceptorNextFunction<Action, State> = (Action?, ((State) -> Void)?) -> Void
