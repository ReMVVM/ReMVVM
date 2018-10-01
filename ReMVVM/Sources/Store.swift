//
//  Store.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import Actions
import Foundation
import MVVM

public typealias StoreState = Any

public class Store<State: StoreState> {

    private let actionDispatcher: ActionsDispatcher
    private(set) public var state: State
    let middleware: [AnyMiddleware]

    public init(with state: State, middleware: [AnyMiddleware] = [], routingEnabled: Bool = false) {
        actionDispatcher = ActionsDispatcher(routingEnabled: routingEnabled)
        self.state = state
        self.middleware = middleware
    }

    public func register<R: Reducer>(reducer: R.Type) where State == R.State {
        actionDispatcher.register(action: reducer.Action.self) { [weak self] in
            self?.handle(param: $0, with: reducer)
        }
    }

    private func handle<Action, R: Reducer>(param: Action.ParamType, with reducer: R.Type) where R.Action == Action, State == R.State {

        let reduce = { [weak self] in
            guard let strongSelf = self else { return }
            let oldState = strongSelf.state
            strongSelf.activeSubscribers.forEach { $0.willChange(state: oldState) }
            strongSelf.state = reducer.reduce(state: oldState, with: param)
            strongSelf.activeSubscribers.forEach { $0.didChange(state: strongSelf.state, oldState: oldState) }
        }

        let getState = { [weak self] in
            return self?.state
        }

        let dispatch = Dispatch<Action>(handler: self,
                                        completion: nil,
                                        middleware: middleware,
                                        getState: getState,
                                        reduce: reduce,
                                        actionParam: param)
        dispatch.next()
    }

    public func handle<Action: StoreAction>(action: Action) {
        actionDispatcher.handle(action: action)
    }

    private var subscribers = [AnyWeakStoreSubscriber<State>]()
    private var activeSubscribers: [AnyWeakStoreSubscriber<State>] {
        subscribers = subscribers.filter { $0.anyValue != nil }
        return subscribers
    }

    public func add<Subscriber>(subscriber: Subscriber) where Subscriber: StoreSubscriber, State == Subscriber.State {
        guard !activeSubscribers.contains(where: { $0.anyValue === subscriber }) else { return }
        subscribers.append(AnyWeakStoreSubscriber(subscriber: subscriber))
    }

    public func remove<Subscriber>(subscriber: Subscriber) where Subscriber: StoreSubscriber, State == Subscriber.State {
        guard let index = activeSubscribers.index(where: { $0.anyValue === subscriber }) else { return }
        subscribers.remove(at: index)
    }
}
