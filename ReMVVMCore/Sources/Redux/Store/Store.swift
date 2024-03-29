//
//  Store.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

#if canImport(Combine)
import Combine
#endif

/**
 Contains application state that can be changed only by dispatching an action.

 Notifies observers of every state change.
 */
public final class Store<State>: Dispatcher, StateSource {

    /// Current state value
    @StateWrapper public var state: State //{ stateClosure() }

    /// Initializes the store
    /// - Parameters:
    ///   - state: initial state of the app
    ///   - reducer: reducer used to generate new app state based on dispatched action and current state
    ///   - middleware:middleware used to enchance action's dispatch functionality
    ///   - stateMappers: application state mappers used to observe application's 'substates'
    ///   - logger: action logger used by this store
    public init<R>(with state: State,
                   reducer: R.Type,
                   middleware: [AnyMiddleware] = [],
                   stateMappers: [StateMapper<State>] = [],
                   logger: Logger = .noLogger) where R: Reducer, R.Action == StoreAction, R.State == State, State: StoreState {

        _state = .init(with: state, reducer: reducer, middleware: middleware, stateMappers: stateMappers, logger: logger)
    }

    init(with mock: MockSource) where State == MockState {
        _state = .init(with: mock)
    }

    init<S>(with store: Store<S>) where State == Any {
        _state = .init(with: store._state.source)
    }

    init<S1, S2>(with store: Store<S1>) where State == Optional<S2> {
        _state = .init(with: store._state.source)
    }

    /// Dishpatches actions in the store. Actions go through middleware and are reduced at the end.
    /// - Parameter action: action to dospatch
    public func dispatch(action: StoreAction, log: Logger.Info) {
        _state.source.dispatch(action: action, log: log)
    }

    /// Adds the state observer. Observer will be notified on every state change occured in the store. It's allowed to add observer for any application's 'substate' - but appropriete StateMapper has to be added during the store initialization.
    /// - Parameter observer: application's state/substate observer. Weak reference is made for the observer so you have to keep the reference by yourself and observer will be automatically removed.
    public func add<Observer>(observer: Observer) where Observer: StateObserver {
        _state.source.add(observer: observer)
    }

    /// Removes state observer.
    /// - Parameter observer: observer to remove
    public func remove<Observer>(observer: Observer) where Observer: StateObserver {
        _state.source.remove(observer: observer)
    }

    @propertyWrapper public final class StateWrapper<State> {

        class Observer<St>: StateObserver {

            let closure: (_ state: St) -> Void
            init(_ closure: @escaping (_ state: St) -> Void) {
                self.closure = closure
            }

            func didReduce(state: St, oldState: St?) {
                closure(state)
            }
        }

        #if canImport(Combine)
        public var wrappedValue: State {
            get {
                if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
                    return stateSubject.value
                } else {
                    return _state as! State
                }
            }

            set {
                if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
                    stateSubject.send(newValue)
                } else {
                    _state = newValue
                }
            }
        }

        private var _state: Any
        @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
        private var stateSubject: CurrentValueSubject<State, Never> {
            _state as! CurrentValueSubject<State, Never>
        }

        @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
        public typealias Publisher = AnyPublisher<State, Never>

        @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
        public var projectedValue: Publisher { stateSubject.eraseToAnyPublisher() }
        #else
        public var wrappedValue: State
        #endif

        let source: AnyStateSource
        var observer: Any!
        init<R>(with state: State,
                reducer: R.Type,
                middleware: [AnyMiddleware] = [],
                stateMappers: [StateMapper<State>] = [],
                logger: Logger) where R: Reducer, R.Action == StoreAction, R.State == State, State: StoreState {

            let store = StateStore(with: state, reducer: reducer, middleware: middleware, stateMappers: stateMappers, logger: logger)
            self.source = store
            #if canImport(Combine)
            if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
                _state = CurrentValueSubject<State, Never>(state)
            } else {
                _state = state
            }
            #else
            wrappedValue = state
            #endif
            let observer = Observer<State> { [unowned self] state in
                self.wrappedValue = state
            }
            self.observer = observer
            store.add(observer: observer)
        }

        init(with source: MockSource) where State == MockState {
            self.source = source
            #if canImport(Combine)
            if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
                _state = CurrentValueSubject<MockState, Never>(source.state)
            } else {
                _state = source.state
            }
            #else
            wrappedValue = source.state
            #endif
            let observer = Observer<State> { [unowned self] state in
                self.wrappedValue = state
            }
            self.observer = observer
            source.add(observer: observer)
        }

        init(with source: AnyStateSource) where State == Any {
            self.source = source
            #if canImport(Combine)
            if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
                _state = CurrentValueSubject<State, Never>(source.anyState)
            } else {
                _state = source.anyState
            }
            #else
            wrappedValue = source.anyState
            #endif
            let observer = Observer<Any> { [unowned self] state in
                self.wrappedValue = state
            }
            self.observer = observer
            source.add(observer: observer)
        }

        init<S>(with source: AnyStateSource) where State == Optional<S> {
            self.source = source
            #if canImport(Combine)
            if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
                _state = CurrentValueSubject<State, Never>(source.mappedState())
            } else {
                _state = (source.mappedState() as S?) as Any
            }
            #else
            wrappedValue = source.mappedState() as S?
            #endif
            let observer = Observer<S> { [unowned self] state in
                self.wrappedValue = state
            }
            self.observer = observer
            source.add(observer: observer)
        }

    }
}

public typealias AnyStore = Store<Any>

extension Store {

    /// Converts to AnyStore
    public var any: Store<Any> {
        .init(with: self)
    }

    /// Converts to Store with specific state type using mappers provided in initialization phase.
    public func mapped<State>() -> Store<State?> {
        .init(with: self)
    }

    /// Creates  Store with  mock (should be used for test purposes only)
    /// - Parameters
    /// - state: initial State
    /// - factory: ViewModelFactory that will be used for ViewModels creation
    /// - onDispatch: closure that will be called when Action is dispatched
    /// - Returns AnyStore instance
    public static func mock<State>(state: State, factory: ViewModelFactory = CompositeViewModelFactory(), onDispatch: MockSource.OnDispatchClosure? = nil) -> AnyStore {
        let source = MockSource(factory: factory, onDispatch: onDispatch)
        source.set(state: state)
        return .mock(source: source)
    }

    /// Creates  Store with  mock (should be used for test purposes only)
    /// - Parameters
    /// - state: initial State
    /// - viewModel: ViewModel instance that is used for tests
    /// - onDispatch: closure that will be called when Action is dispatched
    /// - Returns AnyStore instance
    public static func mock<State, VM>(state: State, viewModel: VM, onDispatch: MockSource.OnDispatchClosure? = nil) -> AnyStore where VM: ViewModel {
        let factory = CompositeViewModelFactory { viewModel }
        return mock(state: state, factory: factory, onDispatch: onDispatch)
    }

    /// Creates  Store with  mock (should be used for test purposes only)
    /// - Parameters
    /// - viewModel: ViewModel instance that is used for tests
    /// - onDispatch: closure that will be called when Action is dispatched
    /// - Returns AnyStore instance
    public static func mock<VM>(viewModel: VM, onDispatch: MockSource.OnDispatchClosure? = nil) -> AnyStore where VM: ViewModel {
        let factory = CompositeViewModelFactory { _ -> VM? in viewModel }
        return mock(factory: factory, onDispatch: onDispatch)
    }

    /// Creates  Store with  mock (should be used for test purposes only)
    /// - Parameters
    /// - factory: ViewModelFactory that will be used for ViewModels creation
    /// - onDispatch: closure that will be called when Action is dispatched
    /// - Returns AnyStore instance
    public static func mock(factory: ViewModelFactory = CompositeViewModelFactory(), onDispatch: MockSource.OnDispatchClosure? = nil) -> AnyStore {
        let source = MockSource(factory: factory, onDispatch: onDispatch)
        return .mock(source: source)
    }

    /// Creates  Store with  mock (should be used for test purposes only)
    /// - Parameters
    /// - source: feeds the Store with mock data.
    /// - Returns AnyStore instance
    public static func mock(source: MockSource) -> AnyStore {
        return Store<MockState>(with: source).any
    }

    public static func test<R>(with state: R.State,
                               reducer: R.Type,
                               middleware: [AnyMiddleware] = [],
                               stateMappers: [StateMapper<R.State>] = [],
                               factory: ViewModelFactory = CompositeViewModelFactory(),
                               onDispatch: ((_ action: StoreAction) -> Void)? = nil) -> AnyStore where R: Reducer, State == Any {

        let state = TestState(factory: factory, state: state)
        let midd: [AnyMiddleware]
        if let onDispatch = onDispatch {
            midd = [TestMiddleware<R.State>(onDispatch: onDispatch)] + middleware
        } else {
            midd = middleware
        }
        let mappers = [StateMapper<TestState<R.State>>(for: \.state)] + stateMappers.map { $0.map(with: \.state) }

        let store = Store<TestState<R.State>>(with: state,
                                              reducer: TestReducer<R>.self,
                                              middleware: midd, stateMappers: mappers,
                                              logger: .defaultTestLogger)



        return store.any
    }
}

struct TestState<S>: StoreState {
    let factory: ViewModelFactory
    let state: S
}

enum TestReducer<R>: Reducer where R: Reducer {

    static func reduce(state: TestState<R.State>, with action: StoreAction) -> TestState<R.State> {
        return TestState(
            factory: state.factory,
            state: R.reduce(state: state.state, with: action)
        )
    }
}

final class TestMiddleware<State>: Middleware {
    let onDispatch: (_ action: StoreAction) -> Void

    init(onDispatch: @escaping (_ action: StoreAction) -> Void) {
        self.onDispatch = onDispatch
    }

    func onNext(for state: State, action: StoreAction, interceptor: Interceptor<StoreAction, State>, dispatcher: Dispatcher) {
        onDispatch(action)
        interceptor.next()
    }


}
