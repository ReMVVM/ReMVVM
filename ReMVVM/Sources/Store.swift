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
        actionDispatcher.register(action: reducer.Action.self) { [unowned self] in
            let oldState = self.state
            self.activeSubscribers.forEach { $0.willChange(state: oldState) }
            self.state = reducer.reduce(state: oldState, with: $0)
            self.activeSubscribers.forEach { $0.didChange(state: self.state, oldState: oldState) }
        }
    }

    public func handle<Action: StoreAction>(action: Action) {
        handle(action: action, completion: nil)
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

extension Store: DispatchHandler {

    func handle<Action: StoreAction>(action: Action, index: Int = 0, completion: ((_ state: Any) -> Void)?) {
        if index == middleware.count {
            actionDispatcher.handle(action: action)
            completion?(state)
        } else {
            middleware[index].middleware(with: action, dispatch: Dispatch(handler: self, index: index, completion: completion), state: state)
        }
    }
}
