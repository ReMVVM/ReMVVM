//
//  File.swift
//  
//
//  Created by Dariusz Grzeszczak on 20/08/2021.
//

#if canImport(Combine)
import Combine
#endif
import Foundation

extension ReMVVM {

    @propertyWrapper
    public final class State<StateType> {

        private lazy var store: Store<StateType?> = ReMVVMConfig.shared.store.mapped()

        /// wrapped value of view model
        public var wrappedValue: StateType? { store.state }

        #if canImport(Combine)
        @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
        public typealias Publisher = Publishers.CompactMap<AnyPublisher<StateType?, Never>, StateType>

        @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
        public var projectedValue: Publisher { store.$state.compactMap { $0 } }
        #endif

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
