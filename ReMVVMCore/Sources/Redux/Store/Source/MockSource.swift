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

    public func dispatch(action: StoreAction) {
        closure(action, source)
    }


}

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
    ///   - state: initial state of the source
    ///   - dispatcher: optional dispatcher
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

    public func set<State>(state: State) {

        let key = String(reflecting: State.self)
        self.state.subStates[key] = state
    }

    public func add<Observer>(observer: Observer) where Observer : StateObserver {
        guard !activeObservers.contains(where: { $0.observer === observer }) else { return }

        let weakObserver: AnyWeakStoreObserver<MockState>
        if Observer.State.self is StoreState.Type || Observer.State.self == Any.self || Observer.State.self == StoreState.self {
            weakObserver = AnyWeakStoreObserver<MockState>(observer: observer)
            observers.append(weakObserver)
            observer.didChange(state: state as! Observer.State, oldState: nil)
        } else {
            let mapper = StateMapper<MockState> { state -> Observer.State in
                let key = String(reflecting: Observer.State.self)
                return state.subStates[key] as! Observer.State
            }

            weakObserver = AnyWeakStoreObserver<MockState>(observer: observer, mapper: mapper) ??
                AnyWeakStoreObserver<MockState>(observer: observer)


            observers.append(weakObserver)

            if let state: Observer.State = mapper.map(state: state) {
                observer.didChange(state: state, oldState: nil)
            }
        }


    }

    public func remove<Observer>(observer: Observer) where Observer : StateObserver {
        guard let index = activeObservers.firstIndex(where: { $0.observer === observer }) else { return }
        observers.remove(at: index)
    }

    func notifyStateWillChange(oldState: MockState) {
        activeObservers.forEach { $0.willChange(state: oldState) }
    }

    func notifyStateDidChange(state: MockState, oldState: MockState) {
        activeObservers.forEach { $0.didChange(state: state, oldState: oldState) }
    }
}

extension MockSource: AnyStateSource {
    var anyState: Any { state }

    public func mappedState<NewState>() -> NewState? {
        let key = String(reflecting: NewState.self)
        return state.subStates[key] as? NewState ?? state as? NewState
    }

    public func dispatch(action: StoreAction) {
        dispatcher?.dispatch(action: action)
    }
}
