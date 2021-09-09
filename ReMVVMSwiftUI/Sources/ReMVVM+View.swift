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

    /// Sets up the ReMVVM source
    /// - parameter store: store that will be used for the source
    public func source(with store: AnyStore) -> some View {
        self.environment(\.remvvmConfig, ReMVVMConfig(store: store))
    }

    /// Sets up the ReMVVM source
    /// - parameter dispatcher: whoose store that will be used for the source
    public func source(from dispatcher: ReMVVM.Dispatcher) -> some View {
        environment(\.remvvmConfig, dispatcher.config)
    }

    /// Sets up the ReMVVM source
    /// - parameter viewModel: whoose store that will be used for the source
    public func source<ViewModel>(from viewModel: ReMVVM.ViewModel<ViewModel>) -> some View {
        environment(\.remvvmConfig, viewModel.config)
    }

    /// Sets up the ReMVVM source
    /// - parameter observedObject: whoose store that will be used for the source
    public func source<Observable>(from observedObject: ReMVVM.ObservedObject<Observable>) -> some View {
        environment(\.remvvmConfig, observedObject.config)
    }

    /// Sets up the ReMVVM source
    /// - parameter state: whoose store that will be used for the source
    public func source<State>(from state: ReMVVM.State<State>) -> some View {
        environment(\.remvvmConfig, state.config)
    }
}

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
