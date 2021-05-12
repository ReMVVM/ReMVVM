//
//  Middleware.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 22/09/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/**

 Middleware associated with specific Action's type. 

 Middleware enchances action's dispatch functionality and may be applied in the store during initialization process. Before action is reduced in the store's reducer it has to go through all middlewares in the stack and each onNext() method has to be called.

 #Rules
 - Middleware intercepts an action to the next middleware in the stack.
 - Action will be reduced in the store only if it leaves last middleware in the stack.
 - Middleware may 'block' action's dispatch by not intercepting it to the next middleware.
 - Middleware also may dispatch completely new action. New action will go through whole middleware stack.

 #Example

     struct ShowUserProfileMiddleware: Middleware {
         let uiState: UIState

         func onNext(for state: AppState, action: ShowUserProfile, interceptor: Interceptor<ShowUserProfile, AppState>, dispatcher: Dispatcher) {

             // block showing user's profile when user is not logged in, redirect to login page instead
             guard state.isUserLoggedIn else {
                 dispatcher.dispatch(action: ShowLoginPage())
             }

             // everything is ok, intercept the action to the next reducer
             interceptor.next { state in
                 // this closure is called after action is handled by reducer - can be used for side effects like that ;)
                 let storyboard = UIStoryboard(name: "Main", bundle: nil)
                 let controller = storyboard.instantiateViewController(withIdentifier: "UserProfileController")
                 self.uiState.showModal(controller: controller)
             }
         }
     }
 */
public protocol Middleware {
    /// type of action handled by this Middleware
    associatedtype Action
    /// type of state handled by this Middleware
    associatedtype State

    /// Method will be called during dispatch process.
    /// - Parameters:
    ///   - state: current state in the store
    ///   - action: action that is dispatched
    ///   - interceptor: allows to intercept action to next middleware by calling next() method. Not calling next()  method blocks action's dispatch process.
    ///   - dispatcher: allows to send completely new action. New action will goo through whole middleware stack.
    func onNext(for state: State, action: Action, interceptor: Interceptor<Action, State>, dispatcher: Dispatcher)
}

extension Middleware {

    public var any: AnyMiddleware {
        AnyMiddleware(middleware: self)
    }
}
