//
//  MockSource.swift
//  
//
//  Created by Dariusz Grzeszczak on 06/08/2021.
//

import Foundation

/**
 Helper  that may be used for testing objects that are based on state sources
 */

//#Example
//    func testViewModel() {
//
//        var state = ApplicationState()
//        let mock = MockSource(with: state)
//        let viewModel = HomeViewModel(with: mock.any)
//
//        XCTAssert(viewModel.isLogged == false)
//
//        state = ApplicationState(user: User(name: "James Bond"))
//        mock.updateState(state: state)
//
//        XCTAssert(viewModel.isLogged == true)
//    }
public final class MockSource<State> {

    private let dispatcher: Dispatcher?

    /// Initializes the source
    /// - Parameters:
    ///   - state: initial state of the source
    ///   - dispatcher: optional dispatcher
    public init(state: State, dispatcher: Dispatcher? = nil) {
        self.state = state
        self.dispatcher = dispatcher
    }

    private let source = StoreSource<State>()

    /// Current state value
    public var state: State {
        willSet {
            source.notifyStateWillChange(oldState: state)
        }

        didSet {
            source.notifyStateDidChange(state: state, oldState: oldValue)
        }
    }
}

extension MockSource: AnyStateSource {
    var anyState: Any {
        state
    }

    func mappedState<NewState>() -> NewState? {
        state as? NewState
    }

    public func dispatch(action: StoreAction) {
        dispatcher?.dispatch(action: action)
    }

    public func add<Observer>(observer: Observer) where Observer : StateObserver {
        if let subscriber = source.add(observer: observer) {
            subscriber.didChange(state: state, oldState: nil)
        }
    }

    public func remove<Observer>(observer: Observer) where Observer : StateObserver {
        source.remove(observer: observer)
    }
}
