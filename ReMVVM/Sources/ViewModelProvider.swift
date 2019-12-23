//
//  ViewModelProvider.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import MVVM

/// Provides view models using current ViewModelFactory from the current state in the store.
public struct ViewModelProvider {

    private let state: () -> StoreState
    private let subject: AnyStateProvider & Subject
    /// Initialize provider with the store
    /// - Parameter store: that will be used to get current view model factory
    public init<State: StoreState>(with store: Store<State>) {
        state = { store.state }
        subject = store
    }

    /// Provides view model of specified type.
    /// - Parameters:
    ///   - context: context that viewModel's lifecycle will be assigned with. Nil means that viewModel's lifecycle will be managed by developer not by ReMVVM.
    ///   - key: optional key that identifies ViewModel type and is used by ViewModelFactory.
    public func viewModel<VM: ViewModel>(for context: ViewModelContext? = nil, with key: String? = nil) -> VM? {

        return getViewModel(for: context, with: key)
    }

    /// Provides view model of specified type and register it for state changes in the store.
    /// - Parameters:
    ///   - context: context that viewModel's lifecycle will be assigned with. Nil means that viewModel's lifecycle will be managed by developer not by ReMVVM.
    ///   - key: optional key that identifies ViewModel type and is used by ViewModelFactory.
    public func viewModel<VM: ViewModel>(for context: ViewModelContext? = nil, with key: String? = nil) -> VM? where VM: StateObserver {

        guard let vm: VM = getViewModel(for: context, with: key) else { return nil }
        subject.add(observer: vm)

        return vm
    }

    /// Returns true if is able to provide view model of specified type.
    /// - Parameter type: view model's type that has to be provided
    public func creates<VM: ViewModel>(type: VM.Type) -> Bool {
        return state().factory.creates(type: VM.self)
    }

    private func getViewModel<VM: ViewModel>(for context: ViewModelContext?, with key: String?) -> VM? {
        let factory = MVVMViewModelFactory(key: key, factory: state().factory)
        guard let context = context else { return factory.create() }

        return ViewModelProviders.provider(for: context, with: factory).get(for: key)
    }

    /// Clears all view models created for specified context.
    /// - Parameter context: context that should be cleared
    public func clear(context: ViewModelContext) {
        ViewModelStores.store(for: context).clear()
    }
}

private struct MVVMViewModelFactory: MVVM.ViewModelFactory {
    let key: String?
    let factory: ViewModelFactory
    func create<VM>() -> VM? {
        return factory.create(key: key)
    }

    init(key: String?, factory: ViewModelFactory) {
        self.key = key
        self.factory = factory
    }
}
