//
//  ReMVVM.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 30/12/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

#if swift(>=5.1)
@propertyWrapper
public final class Provided<VM: ViewModel> {
    private let key: String?
    public private(set) lazy var wrappedValue: VM? = {
        return ReMVVMConfig.defaultReMVVM.viewModelProvider.viewModel(with: key)
    }()

    public init(key: String) {
        self.key = key
    }

    public init() {
        key = nil
    }
}
#endif

//@propertyWrapper
//public final class ReMVVMState<State> {
//    public private(set) var wrappedValue: State?
//    private var subscriber: Subscriber
//    public init() {
//        subscriber = Subscriber()
//        wrappedValue = subscriber.remvvm.state
//        subscriber.update = { state in
//            self.wrappedValue = state
//        }
//        //subscriber.remvvm.add(subscriber: self)
//    }
//
//    private class Subscriber: StateSubscriber, ReMVVMDriven {
//        var update: ((State) -> Void)?
//        init() {
//            self.remvvm.add(subscriber: self)
//        }
//
//
//    }
//}

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
            fatalError("ReMVVM already initialized. You are allowed to have only one store managed by ReMVVM.")
        }
        remvvm = AnyReMVVM(store: store)
    }
}

fileprivate struct AnyReMVVM {

    let store: StoreActionDispatcher & AnyStateSubject
    let viewModelProvider: ViewModelProvider
    init<State: StoreState>(store: Store<State>) {
        viewModelProvider = ViewModelProvider(with: store)
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

    public func viewModel<VM: ViewModel>(for context: ViewModelContext? = nil, for key: String? = nil) -> VM? {
        return remvvm.viewModelProvider.viewModel(for: context, with: key)
    }

    public func viewModel<VM: ViewModel>(for context: ViewModelContext? = nil, for key: String? = nil) -> VM? where VM: StateSubscriber {
        return remvvm.viewModelProvider.viewModel(for: context, with: key)
    }

    public func clear(context: ViewModelContext) {
        remvvm.viewModelProvider.clear(context: context)
    }
}

extension ReMVVM: AnyStateSubject, StateAssociated where Base: StateAssociated {

    public typealias State = Base.State

    public var state: State? { return anyState() }

    public func anyState<State>() -> State? {
        return remvvm.store.anyState()
    }

    public func add<Subscriber: StateSubscriber>(subscriber: Subscriber) {
        remvvm.store.add(subscriber: subscriber)
    }

    public func remove<Subscriber: StateSubscriber>(subscriber: Subscriber) {
        remvvm.store.remove(subscriber: subscriber)
    }
}
