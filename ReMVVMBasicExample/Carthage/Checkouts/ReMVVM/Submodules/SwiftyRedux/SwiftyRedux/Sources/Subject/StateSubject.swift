//
//  StateSubject.swift
//  SwiftyRedux
//
//  Created by Dariusz Grzeszczak on 10/12/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/// Subject with state property
public protocol StateSubject: StateAssociated, Subject {
    /// Current state value
    var state: State? { get }
}

extension StateSubject {
    /// type erased value
    public var any: AnyStateSubject<State> { AnyStateSubject(subject: self) }
}

/// Type erased StateSubject
public struct AnyStateSubject<State>: StateSubject {

    private let _state: () -> State?
    private let subject: Subject

    public var state: State? { _state() }

    public func add<Observer>(observer: Observer) where Observer : StateObserver {
        subject.add(observer: observer)
    }

    public func remove<Observer>(observer: Observer) where Observer : StateObserver {
        subject.remove(observer: observer)
    }

    public init<S: StateSubject>(subject: S) where S.State == State {
        self.subject = subject
        _state = { subject.state }
    }
}
