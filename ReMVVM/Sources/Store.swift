//
//  Store.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import Actions
import MVVM

public class Store<StoreState: State> {

    private let actionDispatcher = ActionsDispatcher(routingEnabled: false)
    private(set) public var state: StoreState

    public init(with state: StoreState) {
        self.state = state
    }

    public var stateWillChange: ((_ oldState: State) -> Void)?
    public var stateDidChange: ((_ newState: State, _ oldState: State) -> Void)?

    public func register<R: Reducer>(reducer: R.Type) where StoreState == R.StoreState {
        actionDispatcher.register(action: reducer.StoreAction.self) { [unowned self] in
            let oldState = self.state
            self.stateWillChange?(oldState)
            self.state = reducer.reduce(state: oldState, with: $0)
            self.stateDidChange?(self.state, oldState)
        }
    }

    public func handle<StoreAction: Action>(action: StoreAction) {
        actionDispatcher.handle(action: action)
    }
}

extension Store: ViewModelProvider {
    public func viewModel<VM>(for context: ViewModelContext, for key: String?) -> VM? {
        let factory = MVVMViewModelFactory(key: key, factory: state.factory)
        return ViewModelProviders.get(for: context, with: factory).get(for: key)
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
