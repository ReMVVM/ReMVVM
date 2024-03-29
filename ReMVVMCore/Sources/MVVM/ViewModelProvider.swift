//
//  ViewModelProvider.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

/// Provides view models using ViewModelFactory from the current state in the store.
public final class ViewModelProvider {

    private let factory: () -> ViewModelFactory
    private let source: AnyStore
    /// Initialize provider with the store
    /// - Parameter store: that will be used to get current view model factory
    public init<State: StoreState>(with store: Store<State>) {
        factory = { store.state.factory }
        source = store.any
    }

    public init(with store: AnyStore) {
        source = store
        if let state: StoreState = store.mapped().state { //todo mapped()
            factory = { state.factory }
        } else {
            factory = { Self.emptyFactory }
        }
    }

    /// Provides view model of specified type.
    /// - Parameters:
//    ///   - context: context that viewModel's lifecycle will be assigned with. Nil means that viewModel's lifecycle will be managed by developer not by ReMVVM.
    ///   - key: optional key that identifies ViewModel type and is used by ViewModelFactory.
    public func viewModel<VM: ViewModel>(/*for context: ViewModelContext? = nil,*/ with key: String? = nil) -> VM? {

        return getViewModel(for: /*context*/nil, with: key)
    }

    /// Provides view model of specified type and register it for state changes in the store.
    /// - Parameters:
//    ///   - context: context that viewModel's lifecycle will be assigned with. Nil means that viewModel's lifecycle will be managed by developer not by ReMVVM.
    ///   - key: optional key that identifies ViewModel type and is used by ViewModelFactory.
    public func viewModel<VM: ViewModel>(/*for context: ViewModelContext? = nil,*/ with key: String? = nil) -> VM? where VM: StateObserver {

        guard let vm: VM = getViewModel(for: /*context*/nil, with: key) else { return nil }
        source.add(observer: vm)

        return vm
    }

    /// Returns true if is able to provide view model of specified type.
    /// - Parameter type: view model's type that has to be provided
    public func creates<VM: ViewModel>(type: VM.Type) -> Bool {
        return factory().creates(type: VM.self)
    }

    private func getViewModel<VM: ViewModel>(for context: ViewModelContext?, with key: String?) -> VM? {
        //let factory = MVVMViewModelFactory(key: key, factory: self.factory())
        guard let context = context else { return factory().create(key: key) }

        return ViewModelProviders.provider(for: context, with: factory()).get(for: key)
    }

// todo add back with context later
//    /// Clears all view models created for specified context.
//    /// - Parameter context: context that should be cleared
//    public func clear(context: ViewModelContext) {
//        ViewModelStores.store(for: context).clear()
//    }

    static let empty: ViewModelProvider = ViewModelProvider(with: Store.empty)//, factory: { emptyFactory } )
    static private let emptyFactory = EmptyFactory()
    private final class EmptyFactory: ViewModelFactory {
        func creates<VM>(type: VM.Type) -> Bool { false }
        func create<VM>(key: String?) -> VM? { nil }
    }
}
