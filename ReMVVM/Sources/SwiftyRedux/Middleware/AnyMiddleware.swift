//
//  AnyMiddleware.swift
//  SwiftyRedux
//
//  Created by Dariusz Grzeszczak on 11/12/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/**
Type erasured Middleware.

#Examples

- Convert Middleware to AnyMiddleware
   ```
   ProfileActionMiddleware().any
   ```
or

 ```
 AnyMiddleware(ProfileActionMiddleware())
 ```
*/
public struct AnyMiddleware {

    private let mapper: Any?
    private let _onNext: (SAIDProvider) -> Bool
    private let stateType: Any.Type

    // Initialize with Middleware
    /// - Parameter middleware: middleware that need to be erased
    public init<M>(middleware: M) where M: Middleware {

        _onNext = { provider in
            guard let said: SAID<M.State, M.Action> = provider.get() else { return false }

            middleware.onNext(for: said.state, action: said.action, interceptor: said.interceptor, dispatcher: said.dispatcher)

            return true
        }

        stateType = M.State.self
        mapper = nil
    }

    /// Method will be called during dispatch process.
    /// - Parameters:
    ///   - state: current state in the store
    ///   - action: action that is dispatched
    ///   - interceptor: allows to intercept action to next middleware by calling next() method. Not calling next()  method blocks action's dispatch process.
    ///   - dispatcher: allows to send completely new action. New action will goo through whole middleware stack.
    public func onNext<State>(for state: State, action: StoreAction, interceptor: Interceptor<StoreAction, State>, dispatcher: Dispatcher) {

        let provider: SAIDProvider
        let said = SAID(state: state, action: action, interceptor: interceptor, dispatcher: dispatcher)
        if let mapper = mapper as? StateMapper<State> {
            provider = SAIDMapperProvider(said: said, mapper: mapper)
        } else {
            provider = SAIDProvider(said: said)
        }

        if !_onNext(provider) {
            interceptor.next()
        }
    }

    init<State>(middleware: AnyMiddleware, mappers: [StateMapper<State>]) {
        stateType = State.self

        if middleware.stateType == State.self {
            _onNext = middleware._onNext
            mapper = middleware.mapper
        } else if let first = mappers.first(where: { $0.matches(state: middleware.stateType )}) {
            _onNext = middleware._onNext
            mapper = first
        } else {
            _onNext = { _ in //stop processing State type not handled (?)
                return false
            }
            mapper = nil
        }
    }
}

private struct SAID<State, Action> { //state, action, interceptor, dispatcher
    let state: State
    let action: Action
    let interceptor: Interceptor<Action, State>
    let dispatcher: Dispatcher
}

private class SAIDProvider {

    let action: Any
    let state: Any
    let interceptor: Any
    let dispatcher: Dispatcher

    init<State>(said: SAID<State, StoreAction>) {
        action = said.action
        state = said.state
        interceptor = said.interceptor
        dispatcher = said.dispatcher
    }

    func get<State, Action>() -> SAID<State, Action>? {
        guard   let action = action as? Action,
                let state = state as? State,
                let intrcptr = interceptor as? Interceptor<StoreAction, State>
        else { return nil }

        let interceptor = Interceptor<Action, State> { act, completion in
            intrcptr.next(action: (act ?? action) as? StoreAction, completion: completion)
        }

        return SAID(state: state, action: action, interceptor: interceptor, dispatcher: dispatcher)
    }
}

private class SAIDMapperProvider<S>: SAIDProvider {
    let mapper: StateMapper<S>

    init<State>(said: SAID<State, StoreAction>, mapper: StateMapper<S>) {
        self.mapper = mapper
        super.init(said: said)
    }

    override func get<State, Action>() -> SAID<State, Action>? {
        guard let action = action as? Action,
            let state = state as? S,
            let newState: State = mapper.map(state: state),
            let intrcptr = interceptor as? Interceptor<StoreAction, S>
        else { return nil }

        let interceptor = Interceptor<Action, S> { act, completion in
            intrcptr.next(action: (act ?? action) as? StoreAction, completion: completion)
        }

        let newInterceptor: Interceptor<Action, State> = map(interceptor: interceptor, mapper: mapper)
        return SAID(state: newState, action: action, interceptor: newInterceptor, dispatcher: dispatcher)
    }

    func map<St, Action>(interceptor: Interceptor<Action, S>, mapper: StateMapper<S>) -> Interceptor<Action,St> {

        Interceptor<Action,St> { action, completion in
            interceptor.next(action: action) { state in
                guard   let completion = completion,
                        let state: St = mapper.map(state: state)
                else { return }
                completion(state)
            }
        }
    }
}
