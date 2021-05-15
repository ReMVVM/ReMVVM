//
//  AnyStore.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

public final class AnyStore: Dispatcher, Source {

    private let store: Dispatcher & Source & AnyStateProvider

    public func dispatch(action: StoreAction) {
        store.dispatch(action: action)
    }

    public func add<Observer>(observer: Observer) where Observer : StateObserver {
        store.add(observer: observer)
    }

    public func remove<Observer>(observer: Observer) where Observer : StateObserver {
        store.remove(observer: observer)
    }

    public func anyState<State>() -> State? {
        return store.anyState()
    }

    public init<State>(store: Store<State>) {
        self.store = store
    }

    //initialize empty
    static let empty: AnyStore = AnyStore()

    private init() { store = EmptyStore() }
    private final class EmptyStore: Dispatcher & Source & AnyStateProvider {
        func dispatch(action: StoreAction) {}

        func add<Observer>(observer: Observer) where Observer : StateObserver { }

        func remove<Observer>(observer: Observer) where Observer : StateObserver { }

        func anyState<State>() -> State? { nil }
    }
}

typealias AnyStateStore = Dispatcher & Source & AnyStateProvider & AnyObject

protocol AnyStateProvider {
    func anyState<State>() -> State?
}

extension Store: AnyStateProvider {
    public var any: AnyStore { AnyStore(store: self) }

    func anyState<State>() -> State? {
        return source.anyState(state: state)
    }
}

extension AnyStore: AnyStateProvider { }
