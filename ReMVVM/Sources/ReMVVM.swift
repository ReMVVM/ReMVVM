//
//  ReMVVM.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 30/12/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public protocol ReMVVMDriven {
    associatedtype Base

    var remvvm: ReMVVM<Base> { get }
    static var remvvm: ReMVVM<Base> { get }
}

public struct ReMVVM<Base> {

    private let remvvm: AnyReMVVM
    fileprivate init(with remvvm: AnyReMVVM) {
        self.remvvm = remvvm
    }
}

public enum ReMVVMConfig {

    fileprivate static var defaultReMVVM: AnyReMVVM {
        guard let remvvm = remvvm else {
            fatalError("ReMVVM has to be initialized first. Please use ReMVVMConfig.initialize(with:) method.")
        }
        return remvvm
    }

    private static var remvvm: AnyReMVVM?
    public static func initialize<State: StoreState>(with store: Store<State>) {
        guard remvvm == nil else {
            assertionFailure("ReMVVM already initialized. Are you sure ?")
            return
        }
        remvvm = AnyReMVVM(store: store)
    }
}

fileprivate struct AnyReMVVM {

    let state: () -> StoreState
    let store: StoreActionDispatcher & AnyStoreStateSubject
    let viewModelProvider: ViewModelProvider
    init<State: StoreState>(store: Store<State>) {
        viewModelProvider = ViewModelProvider(with: store)
        state = { store.state }
        self.store = store
    }
}

extension ReMVVMDriven {

    public var remvvm: ReMVVM<Self> { return ReMVVM(with: ReMVVMConfig.defaultReMVVM) }
    public static var remvvm: ReMVVM<Self> { return ReMVVM(with: ReMVVMConfig.defaultReMVVM) }
}

extension ReMVVM: StoreActionDispatcher {

    public func dispatch(action: StoreAction) {
        remvvm.store.dispatch(action: action)
    }
}

extension ReMVVM where Base: ViewModelContext {

    public func viewModel<VM: ViewModel>(for context: ViewModelContext, for key: String? = nil) -> VM? {
        return remvvm.viewModelProvider.viewModel(for: context, for: key)
    }

    public func viewModel<VM: ViewModel>(for context: ViewModelContext, for key: String? = nil) -> VM? where VM: StoreSubscriber {
        return remvvm.viewModelProvider.viewModel(for: context, for: key)
    }

    public func clear(context: ViewModelContext) {
        remvvm.viewModelProvider.clear(context: context)
    }
}

extension ReMVVM: StoreStateSubject, AnyStoreStateSubject where Base: StoreSubscriber {

    public var state: Base.State? { return remvvm.state() as? Base.State }

    public func add<Subscriber: StoreSubscriber>(subscriber: Subscriber) {
        remvvm.store.add(subscriber: subscriber)
    }

    public func remove<Subscriber: StoreSubscriber>(subscriber: Subscriber) {
        remvvm.store.remove(subscriber: subscriber)
    }
}
