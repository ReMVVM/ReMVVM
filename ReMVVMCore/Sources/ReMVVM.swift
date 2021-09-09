//
//  ReMVVM.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 30/12/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public enum ReMVVM {

    static var _shared: ReMVVMConfig?

    /// Initialize ReMVVM with the store. By default .empty store is used.
    public static func initialize<State: StoreState>(with store: Store<State>) {
        if _shared != nil {
            print("ReMVVM already initialized. Are you sure ?")
        }

        _shared = .init(store: store)
    }
}

//extension ReMVVM {
//
//    public typealias State<State> = ProvidedState<State>
//    public typealias Dispatcher = ProvidedDispatcher
//    public typealias ViewModel = ProvidedViewModel
//}

/// ReMVVM configuration
public final class ReMVVMConfig {

    /// Configured store
    public let store: AnyStore
    /// View model provider associated with the store
    public let viewModelProvider: ViewModelProvider

    init(store: AnyStore, viewModelProvider: ViewModelProvider) {
        self.store = store
        self.viewModelProvider = viewModelProvider
    }

    /// Initialize the configuration with store
    /// - Parameter store used for the configuration
    public init<State>(store: Store<State>) where State: StoreState {
        self.store = store.any
        viewModelProvider = ViewModelProvider(with: store)
    }

    /// Initialize the configuration with store
    /// - Parameter store used for the configuration
    public init(store: AnyStore) {
        self.store = store.any
        viewModelProvider = ViewModelProvider(with: store)
    }

    /// Empty ReMVVM configuration with no state.
    public static let empty = ReMVVMConfig(store: Store.empty, viewModelProvider: .empty)

    /// Shared ReMVVM configuration thats was set by ReMVVM.initialize(), by default ReMVVMConfig.empty is used.
    public static var shared: ReMVVMConfig { ReMVVM._shared ?? .empty}
}
