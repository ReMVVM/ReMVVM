//
//  ReMVVM+View.swift
//  
//
//  Created by Dariusz Grzeszczak on 22/04/2021.
//

#if swift(>=5.1) && canImport(SwiftUI) && canImport(Combine)

import SwiftUI
import Combine
import ReMVVMCore

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    /// Sets up the ReMVVM source
    /// - parameter store: store that will be used for the source
    public func source<Base>(with store: Store<Base>) -> some View where Base: StoreState {
        self.environment(\.remvvmConfig, ReMVVMConfig(store: store))
    }

    public func source(with store: AnyStore) -> some View {
        self.environment(\.remvvmConfig, ReMVVMConfig(store: store))
    }

    /// Sets up the ReMVVM source
    /// - parameter dispatcher: whoose store that will be used for the source
    public func source(from dispatcher: ReMVVM.Dispatcher) -> some View {
        environment(\.remvvmConfig, dispatcher.config)
    }

    public func source<ViewModel>(from viewModel: ReMVVM.ViewModel<ViewModel>) -> some View {
        environment(\.remvvmConfig, viewModel.config)
    }

    public func source<Observable>(from observedObject: ReMVVM.ObservedObject<Observable>) -> some View {
        environment(\.remvvmConfig, observedObject.config)
    }

    public func source<State>(from state: ReMVVM.State<State>) -> some View {
        environment(\.remvvmConfig, state.config)
    }
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
//private final class Mock: Dispatcher, Source, AnyStateStore {
//    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
//    func mappedPublisher<NewState>() -> AnyPublisher<NewState?, Never> {
//        //todo
//        fatalError()
//    }
//
//    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
//    var anyStatePublisher: AnyPublisher<Any, Never> {
//        fatalError() //todo
//    }
//
//
//    private let dispatcher: Dispatcher
//    private let stateSource: AnyStateStore
//
//    func dispatch(action: StoreAction) {
//        dispatcher.dispatch(action: action)
//    }
//
//    func add<Observer>(observer: Observer) where Observer : StateObserver {
//        stateSource.add(observer: observer)
//    }
//
//    func remove<Observer>(observer: Observer) where Observer : StateObserver {
//        stateSource.remove(observer: observer)
//    }
//
//    func mappedState<State>() -> State? {
//        stateSource.mappedState()
//    }
//
//    var anyState: Any {
//        return stateSource.anyState
//    }
//
//    init(source: AnyStateStore, dispatcher: Dispatcher)  {
//        self.stateSource = source
//        self.dispatcher = dispatcher
//    }
//
////
////    init(source: StateSource, factory: ViewModelFactory, dispatcher: Dispatcher) {
////
////    }
//
//}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct StoreEnvKey: EnvironmentKey {
    static var defaultValue: ReMVVMConfig { ReMVVMConfig.shared }
}


@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    var remvvmConfig: ReMVVMConfig {
        get {
            self[StoreEnvKey.self]
        }
        set {
            self[StoreEnvKey.self] = newValue
        }
    }
}
#endif
