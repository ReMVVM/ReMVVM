//
//  File.swift
//  
//
//  Created by Dariusz Grzeszczak on 02/05/2021.
//

#if canImport(SwiftUI) && canImport(Combine)
import Combine
import Foundation
import SwiftUI
import ReMVVMCore

extension ReMVVM {
/**
 A property wrapper that act the same way as ObservedObject but it's observed object contains Sourced or SourcedDispatcher properties.

 ##Example

 ```
public struct DetailsView: View {

    @SourcedObservedObject private var viewState = ViewState()

    private class ViewState: ObservableObject {

        @Published var current: UUID = UUID()

        @Sourced private var state: UUID?
        private var cancellables = Set<AnyCancellable>()

        init() {
            $state
                .assignNoRetain(to: \.current, on: self)
                .store(in: &cancellables)
        }
    }
 
    ...
}
 ```
 */

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    @propertyWrapper
    public struct ObservedObject<Object>: DynamicProperty where Object: ObservableObject {

        @Environment(\.remvvmConfig) private var remvvmConfig
        private var userProvidedStore: AnyStore?
        @SwiftUI.ObservedObject private var wrapper: Wrapper

        /// The underlying value referenced by the observed object.
        public var wrappedValue: Object  {
            get { wrapper.wrappedValue }
            /*nonmutating*/set { wrapper.wrappedValue = newValue }
        }

        /// Initializes property wrapper
        /// - Parameters:
        /// - wrappedValue:  initial wrapped value
        /// - store: user provided store that will be used intsted of ReMVVM provided
        public init(wrappedValue: Object, store: AnyStore? = nil) {
            userProvidedStore = store
            if let userProvidedStore = userProvidedStore { // do not update store when provided by user
                wrapper = .init(store: userProvidedStore, object: wrappedValue)
            } else {
                wrapper = .init(store: ReMVVMConfig.empty.store, object: wrappedValue)
                wrapper.update(store: StoreEnvKey.defaultValue.store) // default value without UI
            }
        }

        /// A projection of the observed object that creates bindings to its
        /// properties using dynamic member lookup.
        public var projectedValue: SwiftUI.ObservedObject<Object>.Wrapper { wrapper.projectedValue }

        /// Updates the underlying value of the stored value.
        public mutating func update() {
            if userProvidedStore == nil { // do not update store when provided by user
                wrapper.update(store: remvvmConfig.store)
            }
        }

        private class Wrapper: StoreUpdatableBase<Any>, ObservableObject {

            var objectWillChange = ObservableObjectPublisher()

            var projectedValue: SwiftUI.ObservedObject<Object>.Wrapper { object.projectedValue }

            var wrappedValue: Object {
                get { object.wrappedValue }
                set {
                    object.wrappedValue = newValue
                    mirror = Mirror(reflecting: newValue)
                    updateObject()
                }
            }

            private var object: SwiftUI.ObservedObject<Object>
            private lazy var mirror: Mirror = Mirror(reflecting: wrappedValue)

            init(store: AnyStore, object: Object) {
                self.object = .init(wrappedValue: object)
                super.init(store: store)
                updateObject()
            }

            override func storeChanged() {
                updateObject()
            }

            private var cancellable: Cancellable?
            private func updateObject() {

                cancellable = nil

                mirror.remvvm_updateStoreUpdatableChildren(store: anyStore)

                cancellable = object.wrappedValue.objectWillChange.sink { [unowned objectWillChange] _ in
                    objectWillChange.send()
                }
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ReMVVM.ObservedObject: ReMVVMConfigProvider {
    var userProvidedConfig: ReMVVMConfig? {
        guard let userProvidedStore = userProvidedStore else { return nil }
        return ReMVVMConfig(store: userProvidedStore)
    }

    var config: ReMVVMConfig { userProvidedConfig ?? remvvmConfig }
}
#endif
