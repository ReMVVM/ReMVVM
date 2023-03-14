//
//  File.swift
//  
//
//  Created by Dariusz Grzeszczak on 06/08/2021.
//

final class StateStore<State>: AnyStateSource {
    
    /// Current state value
    private(set) var state: State
    
    private var middleware: [AnyMiddleware]
    private var middlewareShortcuts: [String: [AnyMiddleware]] = [:]
    
    private let reducer: (State, StoreAction) -> State//AnyReducer<State>
    let source: StoreSource<State>
    private let logger: Logger
    
    /// Initializes the store
    /// - Parameters:
    ///   - state: initial state of the app
    ///   - reducer: reducer used to generate new app state based on dispatched action and current state
    ///   - middleware:middleware used to enchance action's dispatch functionality
    ///   - stateMappers: application state mappers used to observe application's 'substates'
    init<R>(with state: State,
            reducer: R.Type,
            middleware: [AnyMiddleware] = [],
            stateMappers: [StateMapper<State>] = [],
            logger: Logger) where R: Reducer, R.Action == StoreAction, R.State == State, State: StoreState {
        
        self.state = state
        self.middleware = middleware
        self.reducer = reducer.reduce
        self.logger = logger
        source = StoreSource(stateMappers: stateMappers)
    }
    
    func middlewareShorcut(for action: StoreAction) -> [AnyMiddleware] {
        let key = String(reflecting: action)
        let middleware: [AnyMiddleware]
        if let cached = middlewareShortcuts[key] {
            middleware = cached
        } else {
            middleware = self.middleware.filter {
                guard let middleware = $0 as? any Middleware else { return false }
                return middleware.handles(action: action)
            }
            
            middlewareShortcuts[key] = middleware
        }
        
        return middleware
    }

    /// Dishpatches actions in the store. Actions go through middleware and are reduced at the end.
    /// - Parameter action: action to dospatch
    func dispatch(action: StoreAction, log: Logger.Info) {

        logger.logDispatch(action: action, log: log, state: state)
        let middleware = middlewareShorcut(for: action)
        next(middleware: middleware, index: 0, action: action, log: log) { _ in }
//        let semaphore = DispatchSemaphore(value: 0)
//        let t = Thread(target: self, selector: #selector(InternalStore.handle), object: (action, semaphore))
//        t.stackSize = 1024*1024*1024
//        t.start()
//        semaphore.wait()
    }

//    @objc private func handle(action: Any) {
//        let action = action as! (StoreAction, DispatchSemaphore)
//        next(index: 0, action: action.0) { _ in }
//        action.1.signal()
//    }


    private func next(middleware: [AnyMiddleware], index: Int, action: StoreAction, log: Logger.Info, callback: @escaping (State) -> Void) {

        guard index < middleware.count else {
                self.reduce(with: action, log: log)
                callback(self.state)
                return
        }

        let interceptor =  Interceptor<StoreAction, State>(mappers: source.mappers) { [weak self] act, completion in

            self?.next(middleware: middleware, index: index + 1, action: act ?? action, log: log) { state in
                completion?(state)
                callback(state)
            }
        }

        logger.logMiddleware(middleware: middleware[index], action: action, log: log)

        middleware[index].onNext(for: self.state, action: action, interceptor: interceptor, dispatcher: self)
    }

    private func reduce(with action: StoreAction, log: Logger.Info) {
        let oldState = state
        source.notifyStateWillChange(oldState: oldState)
        state = reducer(oldState, action)
        logger.logReduce(state: state, oldState: oldState, action: action, log: log)
        
        source.notifyStateDidChange(state: state, oldState: oldState)
    }


    /// Adds the state observer. Observer will be notified on every state change occured in the store. It's allowed to add observer for any application's 'substate' - but appropriete StateMapper has to be added during the store initialization.
    /// - Parameter observer: application's state/substate observer. Weak reference is made for the observer so you have to keep the reference by yourself and observer will be automatically removed.
    func add<Observer>(observer: Observer) where Observer: StateObserver {
        if let subscriber = source.add(observer: observer) { // new subcriber added with success
            subscriber.didReduce(state: state, oldState: nil)
        }
    }

    /// Removes state observer.
    /// - Parameter observer: observer to remove
    func remove<Observer>(observer: Observer) where Observer: StateObserver {
        source.remove(observer: observer)
    }

    var anyState: Any {
        state
    }

    func mappedState<NewState>() -> NewState? {
        source.anyState(state: state)
    }
}

// ------
// TODO rename
final class StoreSource<State> {

    private var observers = [AnyWeakStoreObserver<State>]()
    private var activeObservers: [AnyWeakStoreObserver<State>] {
        observers = observers.filter { $0.observer != nil }
        return observers
    }

    var mappers: [StateMapper<State>]
    init(stateMappers: [StateMapper<State>] = []) {
        stateMappers.map { $0.newStateType }.forEach { newStateType in
            let count = stateMappers.filter { $0.newStateType == newStateType }.count
            guard count == 1 else {
                fatalError("More state mappers for the same type: \(newStateType)")
            }
        }
        mappers = stateMappers
    }

    func anyState<AnyState>(state: State) -> AnyState? {
        anyStateClosure()(state)
    }

    func anyStateClosure<AnyState>() -> (_ state: State) -> AnyState? {
        if AnyState.self == State.self {
            return { ($0 as! AnyState) }
        }
        if let mapper = mappers.first(where: { $0.matches(state: AnyState.self) }) {
            return { mapper.map(state: $0) }
        } else {
            return { $0 as? AnyState }
        }
    }

    //return nil if subscriber already added
    func add<Observer>(observer: Observer) -> AnyWeakStoreObserver<State>? where Observer: StateObserver {
        guard !activeObservers.contains(where: { $0.observer === observer }) else { return nil }

        //TODO optimize it
        let anyObserver = mappers
            .first { $0.matches(state: Observer.State.self) }
            .flatMap { AnyWeakStoreObserver<State>(observer: observer, mapper: $0) }
            ?? AnyWeakStoreObserver<State>(observer: observer)

        observers.append(anyObserver)
        return anyObserver
    }

    func remove<Observer>(observer: Observer) where Observer : StateObserver {
        guard let index = activeObservers.firstIndex(where: { $0.observer === observer }) else { return }
        observers.remove(at: index)
    }

    func notifyStateWillChange(oldState: State) {
        activeObservers.forEach { $0.willReduce(state: oldState) }
    }

    func notifyStateDidChange(state: State, oldState: State) {
        activeObservers.forEach { $0.didReduce(state: state, oldState: oldState) }
    }
}

