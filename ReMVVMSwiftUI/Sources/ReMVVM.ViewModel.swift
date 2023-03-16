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

        private var userProvidedStore: AnyStore?
        @SwiftUI.ObservedObject private var wrapper: Wrapper

        /// The underlying value referenced by the observed object.
        public var wrappedValue: VM?  {
            wrapper.wrappedValue
        }

        /// A projection of the observed object that creates bindings to its
        /// properties using dynamic member lookup.
        public var projectedValue: SwiftUI.ObservedObject<VM>.Wrapper {
            guard let projectedValue = wrapper.projectedValue else {
                fatalError("ViewModel of type: \(VM.self) not created")
            }
            return projectedValue
        }

        /// Updates the underlying value of the stored value.
        public func update() {
            if userProvidedStore == nil { // do not update store when provided by user
                wrapper.update(store: remvvmConfig.store)
            }
        }

        /// Initializes property wrapper
        /// - Parameters
        /// - key: optional identifier that will be used to create view model by ViewModelProvider
        /// - store: user provided store that will be used intsted of ReMVVM provided
        public init(key: String? = nil, store: AnyStore? = nil) {
            userProvidedStore = store
            if let userProvidedStore = userProvidedStore { // do not update store when provided by user
                wrapper = .init(store: userProvidedStore, key: key)
            } else {
                wrapper = Wrapper(store: ReMVVMConfig.empty.store, key: key)
                wrapper.update(store: StoreEnvKey.defaultValue.store) // default value without UI
            }
        }

        /// Initializes property wrapper
        /// - Parameters
        /// - key: optional identifier that will be used to create view model by ViewModelProvider
        /// - store: user provided store that will be used intsted of ReMVVM provided
        public init(key: String? = nil, store: AnyStore? = nil) where VM: StateObserver {
            userProvidedStore = store
            if let userProvidedStore = userProvidedStore { // do not update store when provided by user
                wrapper = .init(store: userProvidedStore, key: key)
            } else {
                wrapper = Wrapper(store: ReMVVMConfig.empty.store, key: key)
                wrapper.update(store: StoreEnvKey.defaultValue.store) // default value without UI
            }
        }

        fileprivate class Wrapper: StoreUpdatableBase<Any>, ObservableObject {

            var objectWillChange = ObservableObjectPublisher()

            var wrappedValue: VM? { object?.wrappedValue }

            var projectedValue: SwiftUI.ObservedObject<VM>.Wrapper? { object?.projectedValue }

            private var mirror: Mirror?

            private let key: String?
            private lazy var object = { () -> SwiftUI.ObservedObject<VM>? in//var object: ObservedObject<VM>! withhout initialized flag with error
                guard let viewModel: VM = getViewModel() else { return nil }
                let object = SwiftUI.ObservedObject<VM>(wrappedValue: viewModel)
                let mirror = Mirror(reflecting: viewModel)
                updateObject(object: object, mirror: mirror)
                self.mirror = mirror
                return object
            }()

            private var getViewModel: (() -> VM?)!

            init(store: AnyStore, key: String?) {
                self.key = key
                super.init(store: store)
                getViewModel = { [unowned self] in ViewModelProvider(with: self.anyStore).viewModel(with: key) }
            }

            init(store: AnyStore, key: String?) where VM: StateObserver {
                self.key = key
                super.init(store: store)
                getViewModel = { [unowned self] in ViewModelProvider(with: self.anyStore).viewModel(with: key) }
            }

            override func storeChanged() {

                guard let mirror = mirror, let object = object else { return }
                updateObject(object: object, mirror: mirror)
            }

            private var cancellable: Cancellable?
            private func updateObject(object: SwiftUI.ObservedObject<VM>, mirror: Mirror) {

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
extension ReMVVM.ViewModel: ReMVVMConfigProvider {
    var userProvidedConfig: ReMVVMConfig? {
        guard let userProvidedStore = userProvidedStore else { return nil }
        return ReMVVMConfig(store: userProvidedStore)
    }

    var config: ReMVVMConfig { userProvidedConfig ?? remvvmConfig }
}



//@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
//public protocol ViewModelDrivenView: View {
//
//    associatedtype ViewModel: ReMVVMCore.ViewModel
//    var viewModel: ViewModel? { get }
//
//    associatedtype ViewModelBody: View
//    @ViewBuilder func body(with viewMode: ViewModel) -> Self.ViewModelBody
//
//    associatedtype NoViewModelBody: View
//    @ViewBuilder var noViewModelBody: Self.NoViewModelBody { get }
//}
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
//extension ViewModelDrivenView {
//
//    public var noViewModelBody: some View {
//        Text("No view model")
//    }
//
//    @ViewBuilder
//    public var body: some View {
//        if let viewModel = viewModel {
//            body(with: viewModel)
//        } else {
//            noViewModelBody
//        }
//    }
//}
#endif
