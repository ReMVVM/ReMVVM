//
//  Middleware.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 22/09/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public protocol AnyMiddleware {
    func middleware<Action: StoreAction>(with param: Action.ParamType, dispatch: Dispatch<Action>, state: Any)
}

public protocol Middleware: AnyMiddleware {
    associatedtype Action: StoreAction
    associatedtype State: StoreState
    func middleware(with param: Action.ParamType, dispatch: Dispatch<Action>, state: State)
}

extension AnyMiddleware where Self: Middleware {
    public func middleware<Action: StoreAction>(with param: Action.ParamType, dispatch: Dispatch<Action>, state: Any) {
        guard Action.self == Self.Action.self,
            let state = state as? State,
            let par = param as? Self.Action.ParamType,
            let dis = dispatch as? Dispatch<Self.Action>
        else {
            dispatch.next()
            return
        }

        middleware(with: par, dispatch: dis, state: state)
    }
}

protocol DispatchHandler: class {
    func handle<Action: StoreAction>(action: Action)
}

extension Store: DispatchHandler { }

public struct Dispatch<Action: StoreAction> {

    weak var handler: DispatchHandler?
    let completion: ((Any) -> Void)?
    let middleware: [AnyMiddleware]
    let getState: () -> Any
    let reduce: () -> Void

    let actionParam: Action.ParamType

    public func handle<Action: StoreAction>(action: Action) {
        handler?.handle(action: action)
    }

    public func next(completion: ((Any) -> Void)? = nil) {

        let compl = compose(completion1: self.completion, completion2: completion)

        guard !middleware.isEmpty else { // reduce if no more middlewares
            reduce()
            compl?(getState())
            return
        }

        var newWiddleware = middleware
        let first = newWiddleware.removeFirst()
        let dispatch = Dispatch(handler: handler,
                                completion: compl,
                                middleware: newWiddleware,
                                getState: getState,
                                reduce: reduce,
                                actionParam: actionParam)
        first.middleware(with: actionParam, dispatch: dispatch, state: getState())
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
