//
//  ReState.swift
//  
//
//  Created by Dariusz Grzeszczak on 21/04/2021.
//

import Foundation
import ReMVVMCore


#if canImport(Combine) && canImport(SwiftUI)
import Combine
import SwiftUI

extension ReMVVM {
/**
A property wrapper that serves the State from the Store and delivers any State change via the Publisher

 ##Example

 ```
 class DetailsViewModel: ObservableObject, Initializable {

     @Published private(set) var numberFromState: Int = -1

     @Sourced private var state: SwiftUITestState?

     required init() {

         $state.map(\.number).assign(to: &$numberFromState)
     }
 }
 ```
 */

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    @propertyWrapper
    public struct State<State>: DynamicProperty {

        @Environment(\.remvvmConfig) private var remvvmConfig
        private var userProvidedStore: AnyStore?
        private var wrapper: Wrapper

        /// current value of the State
        public var wrappedValue: State? { wrapper.store.state }

        /// Creates the Sourced instance.
        public init(with store: AnyStore? = nil) {
            userProvidedStore = store
            if let userProvidedStore = userProvidedStore { // do not update store when provided by user
                wrapper = .init(store: userProvidedStore)
            } else {
                wrapper = .init(store: ReMVVMConfig.empty.store)
                wrapper.update(store: remvvmConfig.store)
            }
        }

        /// Updates the underlying value of the stored value.
        public func update() {
            if userProvidedStore == nil { // do not update store when provided by user
                wrapper.update(store: remvvmConfig.store)
            }
        }

        /// publisher type
        public typealias Publisher = Publishers.CompactMap<AnyPublisher<State?, Never>, State>
        /// publishes every change of the State
        public var projectedValue: Publisher { wrapper.subject.eraseToAnyPublisher().compactMap { $0 } } 

        private class Wrapper: StoreUpdatableBase<State>, StateObserver {

            var subject: CurrentValueSubject<State?, Never>
            var cancellable: Cancellable?

            override init(store: AnyStore) {
                let state: State? = store.mapped().state //todo (?) mapped state
                subject = CurrentValueSubject<State?, Never>(state)
                super.init(store: store)

                storeChanged()
            }

            override func storeChanged() {
                if store === ReMVVMConfig.empty.store {
                    cancellable = nil
                } else {
                    cancellable = nil
                    cancellable = store.$state.sink { [unowned subject] state in
                        subject.send(state)
                    }
                }
            }
        }

    //    @propertyWrapper
    //    public struct Mapped<Object>: DynamicProperty {
    //
    //        @SwiftUI.State public var wrappedValue: Object
    //
    //        private var cancellable: Cancellable!
    //        private var mapper: ((AnyStateSource<State>.Wrapped.Publisher) -> AnyPublisher<Object, Never>)
    //
    //
    //        public init<Publisher>(_ closure: @escaping (AnyStateSource<State>.Wrapped.Publisher) -> Publisher) where Publisher: Combine.Publisher, Publisher.Output == Object, Publisher.Failure == Never {
    //
    //            mapper = { closure($0).eraseToAnyPublisher() }
    //
    //
    //            cancellable = mapper(ReState<State>().projectedValue).map { $0 }.assign(to: \.wrappedValue, on: self)
    //        }
    //
    //
    //        mutating public func update() {
    //            cancellable = mapper(ReState<State>().projectedValue).map { $0 }.assign(to: \.wrappedValue, on: self)
    //        }
    //
    //        public var projectedValue: Binding<Object> { $wrappedValue }
    //    }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ReMVVM.State: StoreUpdatable {
    func update(store:  AnyStore) {
        wrapper.update(store: store)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ReMVVM.State: ReMVVMConfigProvider {
    var userProvidedConfig: ReMVVMConfig? {
        guard let userProvidedStore = userProvidedStore else { return nil }
        return ReMVVMConfig(store: userProvidedStore)
    }

    var config: ReMVVMConfig { userProvidedConfig ?? remvvmConfig }
}
#endif
