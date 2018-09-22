//
//  StoreSubscriber.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 18/09/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

public protocol StoreSubscriber: class {
    associatedtype State: StoreState

    func willChange(state: State)
    func didChange(state: State, oldState: State)
}

public extension StoreSubscriber {
    public func willChange(state: State) { }
    public func didChange(state: State, oldState: State) { }
}

class AnyWeakStoreSubscriber<State>: StoreSubscriber where State: StoreState {

    private var _willChange: ((_ state: State) -> Void)!
    private var _didChange: ((_ state: State, _ oldState: State) -> Void)!

    private(set) weak var anyValue: AnyObject?

    init<Subscriber>(subscriber: Subscriber) where Subscriber: StoreSubscriber, State == Subscriber.State {
        anyValue = subscriber

        _willChange = { [weak subscriber] state in
            subscriber?.willChange(state: state)
        }

        _didChange = { [weak subscriber] state, oldState in
            subscriber?.didChange(state: state, oldState: oldState)
        }
    }

    func willChange(state: State) {
        _willChange(state)
    }

    func didChange(state: State, oldState: State) {
        _didChange(state, oldState)
    }
}
