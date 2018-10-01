//
//  Middleware.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 22/09/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public protocol AnyMiddleware {
    func apply<Action: StoreAction>(with dispatcher: Dispatcher<Action>, storeState: Any)
}

public protocol Middleware: AnyMiddleware {
    associatedtype Action: StoreAction
    associatedtype State: StoreState
    func apply(with dispatcher: Dispatcher<Action>, storeState: State)
}

extension AnyMiddleware where Self: Middleware {
    public func apply<Action: StoreAction>(with dispatcher: Dispatcher<Action>, storeState: Any) {
        guard Action.self == Self.Action.self,
            let state = storeState as? State,
            let dis = dispatcher as? Dispatcher<Self.Action>
        else {
            dispatcher.next()
            return
        }

        apply(with: dis, storeState: state)
    }
}

protocol StoreActionDispatcher: class {
    func dispatch<Action: StoreAction>(action: Action)
}

extension Store: StoreActionDispatcher { }

public struct Dispatcher<Action: StoreAction> {

    weak var dispatcher: StoreActionDispatcher?
    let completion: ((Any) -> Void)?
    let middleware: [AnyMiddleware]
    let getState: () -> Any
    let reduce: () -> Void

    public let param: Action.ParamType

    public func dispatch<Action: StoreAction>(action: Action) {
        dispatcher?.dispatch(action: action)
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
        let dispatch = Dispatcher(dispatcher: dispatcher,
                                completion: compl,
                                middleware: newWiddleware,
                                getState: getState,
                                reduce: reduce,
                                param: param)
        first.apply(with: dispatch, storeState: getState())
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
