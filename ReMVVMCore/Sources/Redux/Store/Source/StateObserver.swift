//
//  StateObserver.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 18/09/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/// Observes every change of the state
public protocol StateObserver: AnyObject, StateAssociated {

    /// type of state to observe
    associatedtype State
    /// Notifies that state is going to be reduced. Implementation of this method is optional ie. empty implemetation is provided.
    /// - Parameter state: state the is going to be changed
    func willReduce(state: State)
    /// Norifies the state is reduced or initial value is provided while adding to source. Implementation of this method is optional ie. empty implemetation is provided.
    /// - Parameters:
    ///   - state: new state after reduce
    ///   - oldState: previous state or nil when initial value is provided
    func didReduce(state: State, oldState: State?)
}

public extension StateObserver {
    func willReduce(state: State) { }
    func didReduce(state: State, oldState: State?) { }
}

// ------
final class AnyWeakStoreObserver<State>: StateObserver {

    private let _willReduce: ((_ state: Any) -> Void)
    private let _didReduce: ((_ state: Any, _ oldState: Any?) -> Void)

    private(set) weak var observer: AnyObject?

    init<Observer>(observer: Observer) where Observer: StateObserver {

        self.observer = observer

        _willReduce = { [weak observer] state in
            guard   let observer = observer,
                    let state = state as? Observer.State
            else { return }

            observer.willReduce(state: state )
        }

        _didReduce = { [weak observer] state, oldState in
            guard   let observer = observer,
                    let state = state as? Observer.State
            else { return }

            let oldState = oldState as? Observer.State
            observer.didReduce(state: state, oldState: oldState)
        }
    }

    init?<Observer>(observer: Observer, mapper: StateMapper<State>) where Observer: StateObserver {
        guard mapper.matches(state: Observer.State.self) else { return nil }

        self.observer = observer

        _willReduce = { [weak observer] state in
            guard   let observer = observer,
                    let state: Observer.State = mapper.map(state: state as! State)
            else { return }

            observer.willReduce(state: state )
        }

        _didReduce = { [weak observer] state, oldState in
            guard   let observer = observer,
                    let state: Observer.State = mapper.map(state: state as! State)
            else { return }

            guard oldState != nil else {
                observer.didReduce(state: state, oldState: nil)
                return
            }

            guard let oldState: Observer.State = mapper.map(state: oldState as! State) else {
                return
            }

            observer.didReduce(state: state, oldState: oldState)
        }
    }

    func willReduce(state: State) {
        _willReduce(state)
    }

    func didReduce(state: State, oldState: State?) {
        _didReduce(state, oldState)
    }
}
