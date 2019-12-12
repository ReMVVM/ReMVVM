//
//  Middleware.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 22/09/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/// Describes middleware mechanism and works on specific action type. Middleware enchances action's dispatch functionality and may be applied in the store during initialization process. Before action is reduced in the store's reducer it has to go through all middlewares in the stack and theirs onNext() method has to be called. Middleware may intercept action to the next middleware in the stack. Action will be reduced in the store only when it reaches all middlewares in the stack. Middleware may 'block' action's dispatch by not intercepting it to next middleware. Middleware also may dispatch completely new action. New action will go through whole middleware stack.
public protocol Middleware: AnyMiddleware {
    associatedtype Action: StoreAction
    associatedtype State: StoreState

    /// Method will be called during dispatch process.
    /// - Parameters:
    ///   - state: current state in the store
    ///   - action: action that is dispatched
    ///   - interceptor: allows to intercept action to next middleware by calling next() method. Not calling next()  method blocks action's dispatch process.
    ///   - dispatcher: allows to send completely new action. New action will goo through whole middleware stack.
    func onNext(for state: State, action: Action, interceptor: Interceptor<Action, State>, dispatcher: Dispatcher)
}

extension AnyMiddleware where Self: Middleware {
    public func onNext<State: StoreState>(for state: State, action: StoreAction, interceptor: Interceptor<StoreAction, State>, dispatcher: Dispatcher) {
        guard   let action = action as? Self.Action,
                let state = state as? Self.State,
                let inter = interceptor as? Interceptor<StoreAction, Self.State>
        else {
            interceptor.next()
            return
        }

        let interceptor = Interceptor<Self.Action, Self.State> { act, completion in
            inter.next(action: act ?? action, completion: completion)
        }
        onNext(for: state, action: action, interceptor: interceptor, dispatcher: dispatcher)
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
