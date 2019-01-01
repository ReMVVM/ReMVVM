//
//  ReMVVM.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 30/12/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public protocol ReMVVMDriven {
    var remvvm: ReMVVM { get }
}

public struct ReMVVM: StoreActionDispatcher {
    public struct Config {
        fileprivate static var defaultReMVVM: ReMVVM = {
            guard let store = store else {
                fatalError("ReMVVM has to be initialized first. Please use ReMVVM.Config.initialize(with:) method.")
            }

            return ReMVVM(with: store)
        }()

        private static var store: AnyStore?
        public static func initialize(with store: AnyStore) {
            guard Config.store == nil else {
                assertionFailure("ReMVVM already initialized. Are you sure ?")
                return
            }
            Config.store = store
        }
    }

    private let store: AnyStore
    private let viewModelProvider: ViewModelProvider

    public init(with store: AnyStore) {
        self.store = store
        viewModelProvider = ViewModelProvider(with: store)
    }

    public func dispatch(action: StoreAction) {
        store.dispatch(action: action)
    }

    public func viewModel<VM: ViewModel>(for context: ViewModelContext, for key: String? = nil) -> VM? {
        return viewModelProvider.viewModel(for: context, for: key)
    }

    public func viewModel<VM: ViewModel>(for context: ViewModelContext, for key: String? = nil) -> VM? where VM: StoreSubscriber, VM.State: StoreState {
        return viewModelProvider.viewModel(for: context, for: key)
    }

    public func clear(context: ViewModelContext) {
        viewModelProvider.clear(context: context)
    }
}

extension ReMVVMDriven {
    public var remvvm: ReMVVM { return ReMVVM.Config.defaultReMVVM }
}
