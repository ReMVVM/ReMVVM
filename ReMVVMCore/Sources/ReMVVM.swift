//
//  ReMVVM.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 30/12/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public enum ReMVVM {

    static var _shared: ReMVVMConfig?

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

public final class ReMVVMConfig {

    public let store: AnyStore
    public let viewModelProvider: ViewModelProvider

    init(store: AnyStore, viewModelProvider: ViewModelProvider) {
        self.store = store
        self.viewModelProvider = viewModelProvider
    }

    public init<State>(store: Store<State>) where State: StoreState {
        self.store = store.any
        viewModelProvider = ViewModelProvider(with: store)
    }

    public init(store: AnyStore) {
        self.store = store.any
        viewModelProvider = ViewModelProvider(with: store)
    }

    public static let empty = ReMVVMConfig(store: Store.empty, viewModelProvider: .empty)
    public static var shared: ReMVVMConfig { ReMVVM._shared ?? .empty}
}
