//
//  File.swift
//  
//
//  Created by Dariusz Grzeszczak on 02/05/2021.
//

#if swift(>=5.1) && canImport(SwiftUI) && canImport(Combine)
import Combine
import Foundation
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@propertyWrapper
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
public struct SourcedObservedObject<Object>: DynamicProperty where Object: ObservableObject {

    @Environment(\.storeContainer) private var storeContainer

    class Wrapper: EmptyStoreUpdatable, ObservableObject {

        var objectWillChange = ObservableObjectPublisher()

        var wrappedValue: Object {
            get { object.wrappedValue }
            set { object.wrappedValue = newValue } // TODO check update is needed ? 
        }

        var projectedValue: ObservedObject<Object>.Wrapper { object.projectedValue }

        var object: ObservedObject<Object>

        init(store: Dispatcher & Source & AnyStateProvider, object: Object) {
            self.object = .init(wrappedValue: object)
            super.init(store: store)
            updateObject(object: self.object)
        }

        override func storeChanged() {
            updateObject(object: object)
        }

        private var cancellable: Cancellable?
        private func updateObject(object: ObservedObject<Object>) {

            cancellable = nil

            let mirror = Mirror(reflecting: object.wrappedValue)
            for child in mirror.children {
                if let updatable = child.value as? StoreUpdatable {
                    updatable.update(store: store)
                }
            }

            cancellable = object.wrappedValue.objectWillChange.sink { [unowned objectWillChange] _ in
                objectWillChange.send()
            }
        }
    }

    @ObservedObject private var wrapper: Wrapper

    /// The underlying value referenced by the observed object.
    public var wrappedValue: Object  {
        get { wrapper.wrappedValue }
        set { wrapper.wrappedValue = newValue }
    }

    /// A projection of the observed object that creates bindings to its
    /// properties using dynamic member lookup.
    public var projectedValue: ObservedObject<Object>.Wrapper { wrapper.projectedValue }

    /// Updates the underlying value of the stored value.
    public mutating func update() {
        wrapper.update(store: storeContainer.store)
    }

    /// Creates an observed object with an initial wrapped value.
    public init(wrappedValue: Object) {
        wrapper = .init(store: StoreAndViewModelProvider.empty.store, object: wrappedValue)
        wrapper.update(store: storeContainer.store)
    }
}

#endif
