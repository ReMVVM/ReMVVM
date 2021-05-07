//
//  MockStateSource.swift
//  SwiftyRedux
//
//  Created by Dariusz Grzeszczak on 10/12/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/**
 Helper StateSource that may be used for testing objects that are based on state sources

 #Example
     func testViewModel() {

         var state = ApplicationState()
         let mock = MockStateSource(state: state)
         let viewModel = HomeViewModel(with: mock.any)

         XCTAssert(viewModel.isLogged == false)

         state = ApplicationState(user: User(name: "James Bond"))
         mock.updateState(state: state)

         XCTAssert(viewModel.isLogged == true)
     }
 */
public final class MockStateSource<State>: StateSource {

    /// Current state value
    public private(set) var state: State? {
        willSet {
            source.notifyStateWillChange(oldState: state!)
        }

        didSet {
            source.notifyStateDidChange(state: state!, oldState: oldValue!)
        }
    }

    private let source = StoreSource<State>()

    /// Initializes source with the state
    /// - Parameter state: initial state
    public init(state: State) {

        self.state = state
    }

    /// Updates the state in the source
    /// - Parameter state: new state
    public func updateState(state: State) {
        self.state = state
    }

    /// Adds state observer
    /// - Parameter observer: observer to be notified on state changes
    public func add<Observer>(observer: Observer) where Observer: StateObserver {
        if let observer = source.add(observer: observer) { // new subcriber added with success
            observer.didChange(state: state!, oldState: nil)
        }
    }

    /// Removes state observer
    /// - Parameter observer: observer to remove
    public func remove<Observer>(observer: Observer) where Observer: StateObserver {
        source.remove(observer: observer)
    }
}
