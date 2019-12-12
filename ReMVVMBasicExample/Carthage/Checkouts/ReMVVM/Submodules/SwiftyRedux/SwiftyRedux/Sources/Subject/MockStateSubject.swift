//
//  MockStateSubject.swift
//  SwiftyRedux
//
//  Created by Dariusz Grzeszczak on 10/12/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/// Helper StateSubject that can be used for testing objects based on state subjects  eg. ViewModels
public final class MockStateSubject<State>: StateSubject {

    public private(set) var state: State? {
        willSet {
            subject.notifyStateWillChange(oldState: state!)
        }

        didSet {
            subject.notifyStateDidChange(state: state!, oldState: oldValue!)
        }
    }

    private let subject = StoreSubject<State>()

    public init(state: State) {

        self.state = state
    }

    public func updateState(state: State) {
        self.state = state
    }

    public func add<Observer>(observer: Observer) where Observer: StateObserver {
        if let observer = subject.add(observer: observer) { // new subcriber added with success
            observer.didChange(state: state!, oldState: nil)
        }
    }

    public func remove<Observer>(observer: Observer) where Observer: StateObserver {
        subject.remove(observer: observer)
    }
}
