//
//  StateObserver.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 18/09/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/// Observes every change of the state
public protocol StateObserver: class, StateAssociated {

    associatedtype State
    /// Notifies that state is going to be changed. Implementation of this method is optional ie. empty implemetation is provided.
    /// - Parameter state: state the is going to be changed
    func willChange(state: State)
    /// Norifies the state did changed or initial value provided while adding to subject. Implementation of this method is optional ie. empty implemetation is provided.
    /// - Parameters:
    ///   - state: new state after reduce
    ///   - oldState: previous state or nil when initial value is provided
    func didChange(state: State, oldState: State?)
}

public extension StateObserver {
    func willChange(state: State) { }
    func didChange(state: State, oldState: State?) { }
}

// ------

class AnyWeakStoreObserver<State>: StateObserver {

    private let _willChange: ((_ state: Any) -> Void)
    private let _didChange: ((_ state: Any, _ oldState: Any?) -> Void)

    private(set) weak var observer: AnyObject?

    init<Observer>(observer: Observer) where Observer: StateObserver {

        self.observer = observer

        _willChange = { [weak observer] state in
            guard   let observer = observer,
                    let state = state as? Observer.State
            else { return }

            observer.willChange(state: state )
        }

        _didChange = { [weak observer] state, oldState in
            guard   let observer = observer,
                    let state = state as? Observer.State
            else { return }

            let oldState = oldState as? Observer.State
            observer.didChange(state: state, oldState: oldState)
        }
    }

    init?<Observer>(observer: Observer, mapper: StateMapper<State>) where Observer: StateObserver {
        guard mapper.matches(state: Observer.State.self) else { return nil }

        self.observer = observer

        _willChange = { [weak observer] state in
            guard   let observer = observer,
                    let state: Observer.State = mapper.map(state: state as! State)
            else { return }

            observer.willChange(state: state )
        }

        _didChange = { [weak observer] state, oldState in
            guard   let observer = observer,
                    let state: Observer.State = mapper.map(state: state as! State)
            else { return }

            guard oldState != nil else {
                observer.didChange(state: state, oldState: nil)
                return
            }

            guard let oldState: Observer.State = mapper.map(state: oldState as! State) else {
                return
            }

            observer.didChange(state: state, oldState: oldState)
        }
    }

    func willChange(state: State) {
        _willChange(state)
    }

    func didChange(state: State, oldState: State?) {
        _didChange(state, oldState)
    }
}
