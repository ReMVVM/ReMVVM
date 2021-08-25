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

        class Wrapper: StoreUpdatableBase<Any>, ObservableObject {

            var objectWillChange = ObservableObjectPublisher()

            var wrappedValue: Object {
                get { object.wrappedValue }
                set { object.wrappedValue = newValue } // TODO check update is needed ?
            }

            var projectedValue: SwiftUI.ObservedObject<Object>.Wrapper { object.projectedValue }

            var object: SwiftUI.ObservedObject<Object>

            init(store: AnyStore, object: Object) {
                self.object = .init(wrappedValue: object)
                super.init(store: store)
                updateObject(object: self.object)
            }

            override func storeChanged() {
                updateObject(object: object)
            }

            private var cancellable: Cancellable?
            private func updateObject(object: SwiftUI.ObservedObject<Object>) {

                cancellable = nil

                let mirror = Mirror(reflecting: object.wrappedValue)
                for child in mirror.children {
                    if let updatable = child.value as? StoreUpdatable {
                        updatable.update(store: anyStore)
                    }
                }

                cancellable = object.wrappedValue.objectWillChange.sink { [unowned objectWillChange] _ in
                    objectWillChange.send()
                }
            }
        }

        @SwiftUI.ObservedObject private var wrapper: Wrapper

        /// The underlying value referenced by the observed object.
        public var wrappedValue: Object  {
            get { wrapper.wrappedValue }
            set { wrapper.wrappedValue = newValue }
        }

        /// A projection of the observed object that creates bindings to its
        /// properties using dynamic member lookup.
        public var projectedValue: SwiftUI.ObservedObject<Object>.Wrapper { wrapper.projectedValue }

        /// Updates the underlying value of the stored value.
        public mutating func update() {
            wrapper.update(store: remvvmConfig.store)
        }

        /// Creates an observed object with an initial wrapped value.
        public init(wrappedValue: Object) {
            wrapper = .init(store: ReMVVMConfig.empty.store, object: wrappedValue)
            wrapper.update(store: remvvmConfig.store)
        }
    }
}

//@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
//extension ReMVVM {
//
//    public typealias ObservedObject<Object> = ProvidedObservedObject<Object> where Object: ObservableObject
//}
#endif
