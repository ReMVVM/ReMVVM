//
//  Store.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/**
 Contains application state that can be changed only by dispatching an action.

 Notifies observers of every state change.
 */
public class Store<State: StoreState>: Dispatcher, Source {

    /// Current state value
    private(set) public var state: State
    private var middleware: [AnyMiddleware]
    private let reducer: AnyReducer<State>
    private let source: StoreSource<State>

    /// Initializes the store
    /// - Parameters:
    ///   - state: initial state of the app
    ///   - reducer: reducer used to generate new app state based on dispatched action and current state
    ///   - middleware:middleware used to enchance action's dispatch functionality
    ///   - stateMappers: application state mappers used to observe application's 'substates'
    public init(with state: State, reducer: AnyReducer<State>, middleware: [AnyMiddleware] = [], stateMappers: [StateMapper<State>] = []) {
        self.state = state
        self.middleware = middleware.map { AnyMiddleware(middleware: $0, mappers: stateMappers) }
        self.reducer = reducer
        source = StoreSource(stateMappers: stateMappers)
    }

    /// Dishpatches actions in the store. Actions go through middleware and are reduced at the end.
    /// - Parameter action: action to dospatch
    public func dispatch(action: StoreAction) {

        let dispatcher = MiddlewareInterceptor<State>(store: self,
                                                     completion: nil,
                                                     middleware: middleware,
                                                     reduce: { [weak self] in
                                                        self?.reduce(with: action)
                                                     })

        Interceptor<StoreAction, State> { act, completion in
            dispatcher.next(action: act ?? action, completion: completion)
        }.next()
    }

    private func reduce(with action: StoreAction) {
        let oldState = state
        source.notifyStateWillChange(oldState: oldState)
        state = reducer.reduce(state: oldState, with: action)
        source.notifyStateDidChange(state: state, oldState: oldState)
    }


    /// Adds the state observer. Observer will be notified on every state change occured in the store. It's allowed to add observer for any application's 'substate' - but appropriete StateMapper has to be added during the store initialization.
    /// - Parameter observer: application's state/substate observer. Weak reference is made for the observer so you have to keep the reference by yourself and observer will be automatically removed.
    public func add<Observer>(observer: Observer) where Observer: StateObserver {
        if let subscriber = source.add(observer: observer) { // new subcriber added with success
            subscriber.didChange(state: state, oldState: nil)
        }
    }


    /// Removes state observer.
    /// - Parameter observer: observer to remove
    public func remove<Observer>(observer: Observer) where Observer: StateObserver {
        source.remove(observer: observer)
    }
}

// ------

// class is only for use === operator (may be changed if needed)
protocol AnyStateProvider: AnyObject {
    func anyState<State>() -> State?
}

extension Store: AnyStateProvider {
    func anyState<State>() -> State? {
        return source.anyState(state: state)
    }
}

final class StoreSource<State> {

    private var observers = [AnyWeakStoreObserver<State>]()
    private var activeObservers: [AnyWeakStoreObserver<State>] {
        observers = observers.filter { $0.observer != nil }
        return observers
    }

    var mappers: [StateMapper<State>]
    init(stateMappers: [StateMapper<State>] = []) {
        stateMappers.map { $0.newStateType }.forEach { newStateType in
            let count = stateMappers.filter { $0.newStateType == newStateType }.count
            guard count == 1 else {
                fatalError("More state mappers for the same type: \(newStateType)")
            }
        }
        mappers = stateMappers
    }

    func anyState<AnyState>(state: State) -> AnyState? {
        if AnyState.self == State.self { return (state as! AnyState) }
        let anyState: AnyState? = mappers.first { $0.matches(state: AnyState.self) }?.map(state: state)
        return anyState ?? state as? AnyState
    }

    //return nil if subscriber already added
    func add<Observer>(observer: Observer) -> AnyWeakStoreObserver<State>? where Observer: StateObserver {
        guard !activeObservers.contains(where: { $0.observer === observer }) else { return nil }

        //TODO optimize it
        let anyObserver = mappers
            .first { $0.matches(state: Observer.State.self) }
            .flatMap { AnyWeakStoreObserver<State>(observer: observer, mapper: $0) }
            ?? AnyWeakStoreObserver<State>(observer: observer)

        observers.append(anyObserver)
        return anyObserver
    }

    func remove<Observer>(observer: Observer) where Observer : StateObserver {
        guard let index = activeObservers.firstIndex(where: { $0.observer === observer }) else { return }
        observers.remove(at: index)
    }

    func notifyStateWillChange(oldState: State) {
        activeObservers.forEach { $0.willChange(state: oldState) }
    }

    func notifyStateDidChange(state: State, oldState: State) {
        activeObservers.forEach { $0.didChange(state: state, oldState: oldState) }
    }
}
