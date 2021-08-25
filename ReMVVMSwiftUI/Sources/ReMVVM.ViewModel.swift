//
//  ReViewModel.swift
//  
//
//  Created by Dariusz Grzeszczak on 01/12/2020.
//
#if canImport(SwiftUI) && canImport(Combine)
import Combine
import Foundation
import SwiftUI
import ReMVVMCore

extension ReMVVM {
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

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    @propertyWrapper
    public struct ViewModel<VM>: DynamicProperty where VM: ReMVVMCore.ViewModel, VM: ObservableObject {

        @Environment(\.remvvmConfig) private var remvvmConfig

        class Wrapper: StoreUpdatableBase<Any>, ObservableObject {

            var objectWillChange = ObservableObjectPublisher()

            var wrappedValue: VM {
                get { object.wrappedValue }
                set { object.wrappedValue = newValue }
            }

            var projectedValue: SwiftUI.ObservedObject<VM>.Wrapper { object.projectedValue }

            private lazy var object: SwiftUI.ObservedObject<VM> = { //var object: ObservedObject<VM>! withhout initialized flag with error
                let viewModel: VM? = ViewModelProvider(with: anyStore).viewModel(with: key)
    //            if let stateStore: StoreState = store.mapped().state { //todo mapped()  ?
    //                let viewModelProvider = ViewModelProvider(with: anyStore, factory: { stateStore.factory } )
    //                viewModel = viewModelProvider.viewModel(with: key)
    //            } else {
    //                viewModel = nil
    //            }

                let object = SwiftUI.ObservedObject<VM>(wrappedValue: viewModel ?? defaultFactory())
                updateObject(object: object)
                return object
            }()

            private let key: String?
            private let defaultFactory: () -> VM

            init(store: AnyStore, key: String?, defaultFactory: @escaping () -> VM) {
                self.key = key
                self.defaultFactory = defaultFactory
                super.init(store: store)
            }

            init(store: AnyStore, object: VM) {
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
            private func updateObject(object: SwiftUI.ObservedObject<VM>) {

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
        public var wrappedValue: VM  {
            get { wrapper.wrappedValue }
            nonmutating set { wrapper.wrappedValue = newValue }
        }

        /// A projection of the observed object that creates bindings to its
        /// properties using dynamic member lookup.
        public var projectedValue: SwiftUI.ObservedObject<VM>.Wrapper { wrapper.projectedValue }

        /// Updates the underlying value of the stored value.
        public mutating func update() {
            wrapper.update(store: remvvmConfig.store)
        }

        /// Creates an observed view model object with an initial wrapped value.
        public init(wrappedValue: VM) {
            wrapper = Wrapper(store: ReMVVMConfig.empty.store, object: wrappedValue)
            wrapper.update(store: remvvmConfig.store)
        }

        /// Initializes property wrapper
        /// - Parameter defaultValue: closure that creates the default value in case the ViewModelProvider cannot create appropriate view model.
        /// - Parameter key: optional identifier that will be used to create view model by ViewModelProvider
        public init(defaultValue: @escaping @autoclosure () -> VM, key: String? = nil) {
            wrapper = Wrapper(store: ReMVVMConfig.empty.store, key: key, defaultFactory: defaultValue)
            wrapper.update(store: remvvmConfig.store)
        }

        /// Initializes property wrapper
        /// - Parameter defaultValue: closure that creates the default value in case the ViewModelProvider cannot create appropriate view model.
        /// - Parameter key: optional identifier that will be used to create view model by ViewModelProvider
        public init(defaultValue: @escaping @autoclosure () -> VM = VM(), key: String? = nil) where VM: Initializable {
            wrapper = Wrapper(store: ReMVVMConfig.empty.store, key: key, defaultFactory: defaultValue)
            wrapper.update(store: remvvmConfig.store)
        }
    }
}

//@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
//extension ReMVVM {
//
//    public typealias ViewModel = ProvidedViewModel
//}
#endif
