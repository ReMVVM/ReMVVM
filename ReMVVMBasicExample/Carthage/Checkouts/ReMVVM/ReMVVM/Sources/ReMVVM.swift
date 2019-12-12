//
//  ReMVVM.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 30/12/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

/// Main ReMVVM struct. It may be instantiated only by ReMVVM framework. Usually is used by ReMVVMDriven extensions and provide additional methods.
public struct ReMVVM<Base> {

    let store: Dispatcher & Subject & AnyStateProvider
    let viewModelProvider: ViewModelProvider

    init() {
        store = ReMVVM<Any>.store
        viewModelProvider = ReMVVM<Any>.viewModelProvider
    }
}

extension ReMVVM where Base: StoreState {

    /// Initializes ReMVVM framework with the store. ReMVVM is Redux like framework and has the only one store for the app.
    /// - Parameter store: store that will be used by ReMVVM framework.
    public static func initialize(with store: Store<Base>) {
        ReMVVM<Any>.initialize(with: store)
    }
}

extension ReMVVM: Dispatcher {

    /// Dispatches action in the store.
    /// - Parameter action: action to dispatch
    public func dispatch(action: StoreAction) {
        store.dispatch(action: action)
    }
}

extension ReMVVM where Base: ViewModelContext {

    /// Provides view model of specified type.
    /// - Parameters:
    ///   - context: context that viewModel's lifecycle will be assigned with. Nil means that viewModel's lifecycle will be managed by developer not by framework.
    ///   - key: optional key that identifies ViewModel type and is used by ViewModelFactory.
    public func viewModel<VM: ViewModel>(for context: ViewModelContext? = nil, for key: String? = nil) -> VM? {
        return viewModelProvider.viewModel(for: context, with: key)
    }

    /// Provides view model of specified type and register it for state changes in the store.
    /// - Parameters:
    ///   - context: context that viewModel's lifecycle will be assigned with. Nil means that viewModel's lifecycle will be managed by developer not by framework.
    ///   - key: optional key that identifies ViewModel type and is used by ViewModelFactory.
    public func viewModel<VM: ViewModel>(for context: ViewModelContext? = nil, for key: String? = nil) -> VM? where VM: StateObserver {
        return viewModelProvider.viewModel(for: context, with: key)
    }


    /// Clears all view models created for specified context.
    /// - Parameter context: context that should be cleared
    public func clear(context: ViewModelContext) {
        viewModelProvider.clear(context: context)
    }
}

extension ReMVVM where Base: StateAssociated {

    public typealias State = Base.State

    /// state subject that can be used to observe state changes
    public var stateSubject: AnyStateSubject<State> {
        return ReMVVMStateSubject<State>().any
    }

    private struct ReMVVMStateSubject<State>: StateSubject {
        let store: Dispatcher & Subject & AnyStateProvider = ReMVVM<Any>.store
        var state: State? { store.anyState() }

        func add<Observer>(observer: Observer) where Observer : StateObserver {
            store.add(observer: observer)
        }

        func remove<Observer>(observer: Observer) where Observer : StateObserver {
            store.remove(observer: observer)
        }
    }
}

extension ReMVVM where Base == Any {

    static var store: (Dispatcher & Subject & AnyStateProvider)! = {
        guard initialized else {
            fatalError("ReMVVM has to be initialized first. Please use ReMVVM.initialize(with:) method.")
        }

        return nil
    }()

    static var viewModelProvider: ViewModelProvider! = {
        guard initialized else {
            fatalError("ReMVVM has to be initialized first. Please use ReMVVM.initialize(with:) method.")
        }

        return nil
    }()

    private static var initialized: Bool = false
    static func initialize<State: StoreState>(with store: Store<State>) {
        if initialized {
            print("ReMVVM already initialized. Are you sure ?")
        } else {
            initialized = true
        }

        Self.store = store
        viewModelProvider = ViewModelProvider(with: store)
    }
}
