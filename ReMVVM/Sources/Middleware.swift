//
//  Middleware.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 22/09/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public protocol AnyMiddleware {
    func middleware<Action: StoreAction>(with action: Action, dispatch: Dispatch, state: Any)
}

public protocol Middleware: AnyMiddleware {
    associatedtype Action: StoreAction
    associatedtype State: StoreState
    func middleware(with action: Action, dispatch: Dispatch, state: State)
}

extension AnyMiddleware where Self: Middleware {
    public func middleware<Action: StoreAction>(with action: Action, dispatch: Dispatch, state: Any) {
        guard let act = action as? Self.Action, let state = state as? State else {
            dispatch.next(action: action)
            return
        }

        middleware(with: act, dispatch: dispatch, state: state)
    }
}

protocol DispatchHandler {
    func handle<Action: StoreAction>(action: Action, index: Int, completion: ((_ state: Any) -> Void)?)
}

public struct Dispatch {

    let handler: DispatchHandler
    let index: Int
    let completion: ((Any) -> Void)?

    public func handle<Action: StoreAction>(action: Action, completion: ((Any) -> Void)? = nil) {
        handler.handle(action: action, index: 0, completion: completion)
    }

    public func next<Action: StoreAction>(action: Action, completion: ((Any) -> Void)? = nil) {
        handler.handle(action: action,
                       index: index + 1,
                       completion: compose(completion1: self.completion, completion2: completion))
    }

    private func compose(completion1: ((Any) -> Void)?, completion2: ((Any) -> Void)?) -> ((Any) -> Void)? {
        guard let completion1 = completion1 else { return completion2 }
        guard let completion2 = completion2 else { return completion1 }
        return { state in
            completion2(state)
            completion1(state)
        }
    }
}
