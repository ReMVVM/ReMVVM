//
//  ReMVVM+View.swift
//  
//
//  Created by Dariusz Grzeszczak on 22/04/2021.
//

#if swift(>=5.1) && canImport(SwiftUI) && canImport(Combine)

import SwiftUI
import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    /// Sets up the ReMVVM source
    /// - parameter store: store that will be used for the source
    public func source<Base>(with store: Store<Base>) -> some View where Base: StoreState {
        self.environment(\.storeContainer, StoreAndViewModelProvider(store: store))
    }

    /// Sets up the ReMVVM source
    /// - parameter dispatcher: whoose store that will be used for the source
    public func source(from dispatcher: SourcedDispatcher) -> some View {
        return self.environment(\.storeContainer, dispatcher.storeContainer)
    }

//TODO 
//    public func source<Base>(with mock: MockStateSource<Base>, factory: ViewModelFactory = CompositeViewModelFactory(), dispatcher: Dispatcher? = nil) -> some View {
//
//        let mock = Mock(source: mock, dispatcher: dispatcher ?? AnyStore.empty)
//        let viewModelProvider = ViewModelProvider(with: mock, factory: { factory })
//        let store = StoreAndViewModelProvider(store: mock, viewModelProvider: viewModelProvider)
//        return self.environment(\.storeContainer, store)
//    }
}

//private final class MockStore: Dispatcher, Source {
//    private let dispatcher: Dispatcher
//
//    let source: StoreSource<Any>
//
//    init(dispatcher: Dispatcher = AnyStore.empty) {
//        self.dispatcher = dispatcher
//        source = StoreSource(stateMappers: <#T##[StateMapper<_>]#>)
//    }
//
//    func dispatch(action: StoreAction) {
//        dispatcher.dispatch(action: action)
//    }
//
//    func add<Observer>(observer: Observer) where Observer : StateObserver {
//        source.add(observer: observer)
//    }
//
//    func remove<Observer>(observer: Observer) where Observer : StateObserver {
//        source.remove(observer: observer)
//    }
//
//}
private final class Mock: Dispatcher, Source, AnyStateProvider {

    private let dispatcher: Dispatcher
    private let stateSource: Source & AnyStateProvider

    func dispatch(action: StoreAction) {
        dispatcher.dispatch(action: action)
    }

    func add<Observer>(observer: Observer) where Observer : StateObserver {
        stateSource.add(observer: observer)
    }

    func remove<Observer>(observer: Observer) where Observer : StateObserver {
        stateSource.remove(observer: observer)
    }

    func anyState<State>() -> State? {
        stateSource.anyState()
    }

    init(source: Source & AnyStateProvider, dispatcher: Dispatcher)  {
        self.stateSource = source
        self.dispatcher = dispatcher
    }

//
//    init(source: StateSource, factory: ViewModelFactory, dispatcher: Dispatcher) {
//
//    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct StoreEnvKey: EnvironmentKey {
    static var defaultValue: StoreAndViewModelProvider { storeContainer }
}


@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    var storeContainer: StoreAndViewModelProvider {
        get {
            self[StoreEnvKey.self]
        }
        set {
            self[StoreEnvKey.self] = newValue
        }
    }
}
#endif
