//
//  Middleware.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 22/09/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/**

 Middleware associated with specific Action's and State's type. 

 Middleware enchances action's dispatch functionality and may be applied in the store during initialization process. Before action is reduced in the store's reducer it has to go through all middlewares in the stack and each onNext() method has to be called.

 #Rules
 - Middleware intercepts an action to the next middleware in the stack.
 - Action will be reduced by the store only if it is intercepted by the last middleware in the stack.
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
public protocol Middleware: AnyMiddleware {
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

    public func onNext<State>(for state: State, action: StoreAction, interceptor: Interceptor<StoreAction, State>, dispatcher: Dispatcher) {
        let provider: SAIDProvider<State>
        let said = SAID(state: state, action: action, interceptor: interceptor, dispatcher: dispatcher)
        provider = SAIDProvider(said: said)

        guard let saidDst: SAID<Self.State, Self.Action> = provider.get() else {
            interceptor.next()
            return
        }

        onNext(for: saidDst.state, action: saidDst.action, interceptor: saidDst.interceptor, dispatcher: saidDst.dispatcher)
    }

}

private final class SAID<State, Action> { //state, action, interceptor, dispatcher
    let state: State
    let action: Action
    let interceptor: Interceptor<Action, State>
    let dispatcher: Dispatcher

    init(state: State, action: Action, interceptor: Interceptor<Action, State>, dispatcher: Dispatcher) {
        self.state = state
        self.action = action
        self.interceptor = interceptor
        self.dispatcher = dispatcher
    }
}

private class SAIDProvider<S> {

    let action: StoreAction
    let state: S
    let interceptor: Interceptor<StoreAction, S>
    let dispatcher: Dispatcher

    init(said: SAID<S, StoreAction>) {
        action = said.action
        state = said.state
        interceptor = said.interceptor
        dispatcher = said.dispatcher
    }

    func get<State, Action>() -> SAID<State, Action>? {
        guard let action = action as? Action else { return nil }

        let closure: (S) -> State? = anyStateClosure()
        guard let state = closure(state) as State?//, let intrcptr = interceptor as? Interceptor<StoreAction, State>
        else { return nil }

        let interceptor = Interceptor<Action, State>(mappers: []) { act, completion in
            self.interceptor.next(action: (act ?? action) as? StoreAction) { state in
                guard let completion = completion, let state = closure(state) else { return}
                completion(state)
            }
        }

        return SAID(state: state, action: action, interceptor: interceptor, dispatcher: dispatcher)
    }

    func anyStateClosure<AnyState>() -> (_ state: S) -> AnyState? { // todo the  same as in source 
        if AnyState.self == S.self {
            return { ($0 as! AnyState) }
        }
        if let mapper = interceptor.mappers.first(where: { $0.matches(state: AnyState.self) }) {
            return { mapper.map(state: $0) }
        } else {
            return { $0 as? AnyState }
        }
    }
}

//@resultBuilder
//public struct MiddlewareBuilder {
//    public init() { }
//    public static func buildBlock(_ items: AnyMiddlewareConvertible...) -> [AnyMiddleware] {
//        fatalError()
//        //return items.map { "Hello \($0)" }
//    }
//}
