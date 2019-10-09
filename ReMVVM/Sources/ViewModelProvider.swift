//
//  ViewModelProvider.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import MVVM

public struct ViewModelProvider {

    private let state: () -> StoreState
    private let subject: AnyStateSubject
    public init<State: StoreState>(with store: Store<State>) {
        state = { store.state }
        subject = store
    }

    // context that viewModel will be assigned with, nil means dev takes care of manage VM's lifecycle
    public func viewModel<VM: ViewModel>(for context: ViewModelContext? = nil, with key: String? = nil) -> VM? {

        return getViewModel(for: context, with: key)
    }

    // context that viewModel will be assigned with, nil means dev takes care of manage VM's lifecycle
    public func viewModel<VM: ViewModel>(for context: ViewModelContext? = nil, with key: String? = nil) -> VM? where VM: StateSubscriber {

        guard let vm: VM = getViewModel(for: context, with: key) else { return nil }
        subject.add(subscriber: vm)

        return vm
    }

    public func creates<VM: ViewModel>(type: VM.Type) -> Bool {
        return state().factory.creates(type: VM.self)
    }

    private func getViewModel<VM: ViewModel>(for context: ViewModelContext?, with key: String?) -> VM? {
        let factory = MVVMViewModelFactory(key: key, factory: state().factory)
        guard let context = context else { return factory.create() }

        return ViewModelProviders.provider(for: context, with: factory).get(for: key)
    }

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
