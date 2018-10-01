//
//  ViewModelProvider.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import MVVM

public struct ViewModelProvider<State: StoreState> {

    private let store: Store<State>
    public init(with store: Store<State>) {
        self.store = store
    }

    public func viewModel<VM: ViewModel>(for context: ViewModelContext, for key: String? = nil) -> VM? {
        let factory = MVVMViewModelFactory(key: key, factory: store.state.factory)
        return ViewModelProviders.get(for: context, with: factory).get(for: key)
    }

    public func viewModel<VM: ViewModel>(for context: ViewModelContext, for key: String? = nil) -> VM? where VM: StoreSubscriber, VM.State == State {
        let factory = MVVMViewModelFactory(key: key, factory: store.state.factory)
        guard let vm: VM = ViewModelProviders.get(for: context, with: factory).get(for: key) else { return nil }
        store.add(subscriber: vm)
        return vm
    }

    public func clear(context: ViewModelContext) {
        ViewModelStores.get(for: context).clear()
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
