//
//  ReViewModel.swift
//  
//
//  Created by Dariusz Grzeszczak on 01/12/2020.
//
#if swift(>=5.1) && canImport(SwiftUI) && canImport(Combine)
import Combine
import Foundation
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@propertyWrapper
public struct SourcedViewModel<VM>: DynamicProperty where VM: ViewModel, VM: ObservableObject {

    @Environment(\.storeContainer) private var storeContainer

    class Wrapper: EmptyStoreUpdatable, ObservableObject {

        //private let _objectWillChange = ObservableObjectPublisher()
        var objectWillChange = ObservableObjectPublisher()

        var wrappedValue: VM {
            get { object.wrappedValue }
            set { object.wrappedValue = newValue }
        }

        var projectedValue: ObservedObject<VM>.Wrapper { object.projectedValue }

        private lazy var object: ObservedObject<VM> = { //var object: ObservedObject<VM>! withhout initialized flag with error
            let viewModel: VM?
            if let stateStore: StoreState = store.anyState() {
                let viewModelProvider = ViewModelProvider(with: store, factory: { stateStore.factory } )
                viewModel = viewModelProvider.viewModel(with: key)
            } else {
                viewModel = nil
            }

            let object = ObservedObject<VM>(wrappedValue: viewModel ?? defaultFactory())
            updateObject(object: object)
            return object
        }()

        private let key: String?
        private let defaultFactory: () -> VM

        init(store: Dispatcher & Source & AnyStateProvider, key: String?, defaultFactory: @escaping () -> VM) {
            self.key = key
            self.defaultFactory = defaultFactory
            super.init(store: store)
        }

        init(store: Dispatcher & Source & AnyStateProvider, object: VM) {
            defaultFactory = { object }
            key = nil
            super.init(store: store)
            self.object = .init(wrappedValue: object)
            updateObject(object: self.object)
        }

        override func storeChanged() {
            updateObject(object: object)
        }

        private var cancellable: Cancellable?
        private func updateObject(object: ObservedObject<VM>) {

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

    public var wrappedValue: VM  {
        get { wrapper.wrappedValue }
        nonmutating set { wrapper.wrappedValue = newValue }
    }

    public mutating func update() {
        wrapper.update(store: storeContainer.store)
    }

    public init(wrappedValue: VM) {
        wrapper = Wrapper(store: StoreAndViewModelProvider.empty.store, object: wrappedValue)
        wrapper.update(store: storeContainer.store)
    }

    public init(wrappedValue: VM) where VM: Initializable {
        wrapper = Wrapper(store: StoreAndViewModelProvider.empty.store, object: wrappedValue)
        wrapper.update(store: storeContainer.store)
    }


    /// Initializes property wrapper
    /// - Parameter key: optional identifier that will be used to create view model by ViewModelProvider
    public init(defaultValue: @escaping @autoclosure () -> VM, key: String? = nil) {
        wrapper = Wrapper(store: StoreAndViewModelProvider.empty.store, key: key, defaultFactory: defaultValue)
        wrapper.update(store: storeContainer.store)
    }

    /// Initializes property wrapper
    /// - Parameter key: optional identifier that will be used to create view model by ViewModelProvider
    public init(defaultValue: @escaping @autoclosure () -> VM = VM(), key: String? = nil) where VM: Initializable {
        wrapper = Wrapper(store: StoreAndViewModelProvider.empty.store, key: key, defaultFactory: defaultValue)
        wrapper.update(store: storeContainer.store)
    }

    public var projectedValue: ObservedObject<VM>.Wrapper { wrapper.projectedValue }
}
#endif
