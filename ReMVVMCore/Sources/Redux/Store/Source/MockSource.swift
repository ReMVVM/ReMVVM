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

struct MockState: StoreState {
    let factory: ViewModelFactory
    var subStates: [String: Any]
}

private final class MockDispatcher: Dispatcher {

    unowned var source: MockSource
    let closure: MockSource.OnDispatchClosure

    public init(source: MockSource, closure: @escaping MockSource.OnDispatchClosure) {
        self.closure = closure
        self.source = source
    }

    public func dispatch(action: StoreAction, log: Logger.Info) {
        closure(action, source)
    }


}

/// Source that is used to feed the Store with mock data, used for testing purposes.
public final class MockSource {

    public typealias OnDispatchClosure = (_ action: StoreAction, _ source: MockSource) -> Void

    private var dispatcher: Dispatcher?
    private var observers: [AnyWeakStoreObserver<MockState>] = []
    private var activeObservers: [AnyWeakStoreObserver<MockState>] {
        observers = observers.filter { $0.observer != nil }
        return observers
    }

    /// Initializes the source
    /// - Parameters:
    ///   - factory: ViewModelFactory that will be used for ViewModels creation
    ///   - onDispatch: closure that will be called when Action is dispatched
    public init(factory: ViewModelFactory = CompositeViewModelFactory(), onDispatch: OnDispatchClosure? = nil) {
        self.state = MockState(factory: factory, subStates: [:])
        if let onDispatch = onDispatch {
            self.dispatcher = MockDispatcher(source: self, closure: onDispatch)
        }
    }

    /// Current state value
    var state: MockState {
        willSet {
            notifyStateWillChange(oldState: state)
        }

        didSet {
            notifyStateDidChange(state: state, oldState: oldValue)
        }
    }

    /// Sets the State that will be served by MockSource
    /// - Parameter state: state of the specific type. You can set multiple states with different type if needed.
    public func set<State>(state: State) {

        let key = String(reflecting: State.self)
        self.state.subStates[key] = state
    }

    /// Adds state observer
    /// - Parameter observer: observer to be notified on state changes
    public func add<Observer>(observer: Observer) where Observer : StateObserver {
        guard !activeObservers.contains(where: { $0.observer === observer }) else { return }

        let weakObserver: AnyWeakStoreObserver<MockState>
        if Observer.State.self is StoreState.Type || Observer.State.self == Any.self || Observer.State.self == StoreState.self {
            weakObserver = AnyWeakStoreObserver<MockState>(observer: observer)
            observers.append(weakObserver)
            observer.didReduce(state: state as! Observer.State, oldState: nil)
        } else {
            let mapper = StateMapper<MockState> { state -> Observer.State in
                let key = String(reflecting: Observer.State.self)
                return state.subStates[key] as! Observer.State
            }

            weakObserver = AnyWeakStoreObserver<MockState>(observer: observer, mapper: mapper) ??
                AnyWeakStoreObserver<MockState>(observer: observer)


            observers.append(weakObserver)

            if let state: Observer.State = mapper.map(state: state) {
                observer.didReduce(state: state, oldState: nil)
            }
        }


    }

    /// Removes state observer
    /// - Parameter observer: observer to remove
    public func remove<Observer>(observer: Observer) where Observer : StateObserver {
        guard let index = activeObservers.firstIndex(where: { $0.observer === observer }) else { return }
        observers.remove(at: index)
    }

    func notifyStateWillChange(oldState: MockState) {
        activeObservers.forEach { $0.willReduce(state: oldState) }
    }

    func notifyStateDidChange(state: MockState, oldState: MockState) {
        activeObservers.forEach { $0.didReduce(state: state, oldState: oldState) }
    }
}

extension MockSource: AnyStateSource {
    var anyState: Any { state }

    /// Returns the current state for specific type or nil if not available.
    func mappedState<NewState>() -> NewState? {
        let key = String(reflecting: NewState.self)
        return state.subStates[key] as? NewState ?? state as? NewState
    }

    /// Dishpatches an action.
    /// - Parameter action: action to dispach
    public func dispatch(action: StoreAction, log: Logger.Info) {
        dispatcher?.dispatch(action: action, log: log)
    }
}
