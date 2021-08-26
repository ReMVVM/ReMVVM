//
//  File.swift
//  
//
//  Created by Dariusz Grzeszczak on 20/08/2021.
//

import Foundation

extension ReMVVM {

    @propertyWrapper
    public final class State<StateType> {

        private lazy var store: Store<StateType?> = ReMVVMConfig.shared.store.mapped()

        /// wrapped value of view model
        public var wrappedValue: StateType? { store.state }

        /// Initializes property wrapper
        public init(with store: Store<StateType?>? = nil)  {
            if let store = store {
                self.store = store
            }
        }
    }
}

extension ReMVVM.State: StateSource {

    public typealias State = StateType?

    public var state: State { wrappedValue }

    public func add<Observer>(observer: Observer) where Observer : StateObserver {
        store.add(observer: observer)
    }

    public func remove<Observer>(observer: Observer) where Observer : StateObserver {
        store.remove(observer: observer)
    }
}
