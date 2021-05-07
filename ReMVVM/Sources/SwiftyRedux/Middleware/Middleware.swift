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

// ------

struct MiddlewareInterceptor<State: StoreState> {
    weak var store: Store<State>?
    let completion: ((State) -> Void)?
    let middleware: [AnyMiddleware]
    let reduce: () -> Void

    func next(action: StoreAction, completion: ((State) -> Void)? = nil) {

        guard let store = store else { return } // store dealocated no need to do

        let compl = compose(completion1: self.completion, completion2: completion)

        guard !middleware.isEmpty else { // reduce if no more interceptor
            reduce()
            compl?(store.state)
            return
        }

        var newWiddleware = middleware
        let first = newWiddleware.removeFirst()
        let middlewareInterceptor = MiddlewareInterceptor(store: store, completion: compl, middleware: newWiddleware, reduce: reduce)

        let interceptor =  Interceptor<StoreAction, State> { act, completion in
            middlewareInterceptor.next(action: act ?? action, completion: completion)
        }
        first.onNext(for: store.state, action: action, interceptor: interceptor, dispatcher: store)
    }

    private func compose(completion1: ((State) -> Void)?, completion2: ((State) -> Void)?) -> ((State) -> Void)? {
        guard let completion1 = completion1 else { return completion2 }
        guard let completion2 = completion2 else { return completion1 }
        return { state in
            completion2(state)
            completion1(state)
        }
    }
}
