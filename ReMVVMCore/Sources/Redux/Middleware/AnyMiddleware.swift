//
//  AnyMiddleware.swift
//  SwiftyRedux
//
//  Created by Dariusz Grzeszczak on 11/12/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/**

Middleware enchances action's dispatch functionality and may be applied in the store during initialization process. Before action is reduced in the store's reducer it has to go through all middlewares in the stack and each onNext() method has to be called.

#Rules
- Middleware intercepts an action to the next middleware in the stack.
- Action will be reduced in the store only if it leaves last middleware in the stack.
- Middleware may 'block' action's dispatch by not intercepting it to the next middleware.
- Middleware also may dispatch completely new action. New action will go through whole middleware stack.

#Example
     // Put it as first middleware to just 'track' all actions
     public struct TrackDispatchMiddleware: AnyMiddleware {

         let printDebugInfo: Bool

         public func onNext<State>(for state: State, action: StoreAction, interceptor: Interceptor<StoreAction, State>, dispatcher: Dispatcher) where State : StoreState {

             // debug disabled - just intercept the action
             guard printDebugInfo else { interceptor.next() }

             print("Action: \(action) is going to be dispatched with state: \(state)")
             interceptor.next { state in
                 print("Action dispatched. New state: \(state)")
             }
         }
     }
*/


public protocol AnyMiddleware {

    func onNext<State>(for state: State, action: StoreAction, interceptor: Interceptor<StoreAction, State>, dispatcher: Dispatcher)
}
