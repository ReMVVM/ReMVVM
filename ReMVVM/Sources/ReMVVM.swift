//
//  ReMVVM.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 30/12/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

//RxSwift snippet for action observer
//public extension StoreActionDispatcher where Self: ObserverType {
//    public func on(_ event: Event<StoreAction>) {
//        guard let action = event.element else { return }
//        self.dispatch(action: action)
//    }
//}
//extension SwiftyRedux.Store: ObserverType { }
//extension ReMVVM: ObserverType { }
//extension Dispatcher: ObserverType { }
//extension AnyDispatcher: ObserverType { }

public protocol ReMVVMDriven {
    var remvvmScope: String { get }
    var remvvm: ReMVVM { get }
}

extension ReMVVMDriven {
    public var remvvmScope: String { return ReMVVM.Config.defaultScope }
}

public struct ReMVVM: StoreActionDispatcher {
    public struct Config {
        public static let defaultScope = "default"

        private static var remvvm: [String: ReMVVM] = [:]
        public static func initialize(scope: String = defaultScope, with store: AnyStore) {
            guard !remvvm.keys.contains(scope) else {
                fatalError("ReMVVM already initialized for scope: \(scope).")
            }
            remvvm[scope] = ReMVVM(with: store)
        }

        fileprivate static func remvvm(for scope: String) -> ReMVVM {
            guard let remmvvm = ReMVVM.Config.remvvm[scope] else {
                fatalError("ReMVVM not initialized for scope: \(scope). Please uee ReMVVM.Config.initialize(scope: with:) method first.")
            }

            return remmvvm
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
    public var remvvm: ReMVVM { return ReMVVM.Config.remvvm(for: remvvmScope) }
}
