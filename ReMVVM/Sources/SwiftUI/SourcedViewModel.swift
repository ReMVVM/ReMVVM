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
/**
A property wrapper that serves observable view model object.

 ##Example

 ```
struct DetailsView: View {

    @SourcedDispatcher var dispatcher
    @SourcedViewModel private var viewModel: DetailsViewModel

    var body: some View {
        VStack {
            Text("state number: \(viewModel.numberFromState)")
            Button(action: dispatcher[NumberAction.increase(by: 1)]) {
                Text("Increase by 1")
            }
            Button(action: dispatcher[NumberAction.decrease(by: 1)]) {
                Text("Decrease by 1")
            }
        }
    }
}

class DetailsViewModel: ObservableObject, Initializable {

    @Published private(set) var numberFromState: Int = -1

    @Sourced private var state: AppState?

    required init() {

        $state.map(\.number).assign(to: &$numberFromState)
    }
}
 ```
 */

    public struct SourcedViewModel<VM>: DynamicProperty where VM: ViewModel, VM: ObservableObject {

    @Environment(\.storeContainer) private var storeContainer

    class Wrapper: EmptyStoreUpdatable, ObservableObject {

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

    /// The underlying value referenced by the observed object.
    public var wrappedValue: VM  {
        get { wrapper.wrappedValue }
        nonmutating set { wrapper.wrappedValue = newValue }
    }

    /// A projection of the observed object that creates bindings to its
    /// properties using dynamic member lookup.
    public var projectedValue: ObservedObject<VM>.Wrapper { wrapper.projectedValue }

    /// Updates the underlying value of the stored value.
    public mutating func update() {
        wrapper.update(store: storeContainer.store)
    }

    /// Creates an observed view model object with an initial wrapped value.
    public init(wrappedValue: VM) {
        wrapper = Wrapper(store: StoreAndViewModelProvider.empty.store, object: wrappedValue)
        wrapper.update(store: storeContainer.store)
    }

    /// Initializes property wrapper
    /// - Parameter defaultValue: closure that creates the default value in case the ViewModelProvider cannot create appropriate view model.
    /// - Parameter key: optional identifier that will be used to create view model by ViewModelProvider
    public init(defaultValue: @escaping @autoclosure () -> VM, key: String? = nil) {
        wrapper = Wrapper(store: StoreAndViewModelProvider.empty.store, key: key, defaultFactory: defaultValue)
        wrapper.update(store: storeContainer.store)
    }

    /// Initializes property wrapper
    /// - Parameter defaultValue: closure that creates the default value in case the ViewModelProvider cannot create appropriate view model.
    /// - Parameter key: optional identifier that will be used to create view model by ViewModelProvider
    public init(defaultValue: @escaping @autoclosure () -> VM = VM(), key: String? = nil) where VM: Initializable {
        wrapper = Wrapper(store: StoreAndViewModelProvider.empty.store, key: key, defaultFactory: defaultValue)
        wrapper.update(store: storeContainer.store)
    }
}
#endif
