//
//  File.swift
//  
//
//  Created by Dariusz Grzeszczak on 06/08/2021.
//
import Foundation

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
            dispatchQueue: DispatchQueue,
            logger: Logger) where R: Reducer, R.Action == StoreAction, R.State == State, State: StoreState {
        
        self.state = state
        self.middleware = middleware
        self.reducer = reducer.reduce
        self.logger = logger
        self.dispatchQueue = dispatchQueue
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

    private let dispatchQueue: DispatchQueue
    /// Dishpatches actions in the store. Actions go through middleware and are reduced at the end.
    /// - Parameter action: action to dospatch
    func dispatch(actions: [StoreAction], log: Logger.Info) {
        dispatchQueue.async { [weak self] in
            for action in actions {
                guard let self else { return }
                self.logger.logDispatch(action: action, log: log, state: self.state)
                let middleware = self.middlewareShorcut(for: action)
                self.dispatch(action: action, middleware: middleware, log: log)
            }
        }
    }
    
    private class Dispatch {
        let middleware: [AnyMiddleware]
        var action: StoreAction
        let log: Logger.Info
        var middlewareOffset = -1
        var completions: [(State) -> Void] = []
        
        init(action: StoreAction, middleware: [AnyMiddleware], log: Logger.Info) {
            self.action = action
            self.middleware = middleware
            self.log = log
        }
        
    }
    
    private func dispatch(action: StoreAction, middleware: [AnyMiddleware], log: Logger.Info) {
        let dispatch = Dispatch(action: action, middleware: middleware, log: log)
        
        for middleware in middleware.enumerated() {
            let interceptor =  Interceptor<StoreAction, State>(mappers: source.mappers) { [weak dispatch, logger] act, completion in
                
                guard let dispatch else {
                    logger.logWarning(message: """
                                        interceptor.next() called outside thread, ignoring that call in \(String(reflecting: type(of: middleware.element)))
                                        """, log: log)
                    return
                }
                guard dispatch.middlewareOffset == middleware.offset - 1 else {
                    logger.logWarning(message: """
                                        interceptor.next() called multiple times, ignoring that call in \(String(reflecting: type(of: middleware.element)))
                                        """, log: log)
                    return
                }
                if let act { dispatch.action = act }
                if let completion { dispatch.completions.append(completion) }
                dispatch.middlewareOffset = middleware.offset
            }
            
            logger.logMiddleware(middleware: middleware.element, action: action, log: log)
            middleware.element.onNext(for: state, action: dispatch.action, interceptor: interceptor, dispatcher: self)
            if dispatch.middlewareOffset != middleware.offset {
                break
            }
        }
        
        if dispatch.middlewareOffset == dispatch.middleware.count - 1 {
            reduce(with: action, log: log)
            dispatch.completions.reversed().forEach {
                $0(state)
            }
        }
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

