//
//  ReDispatcher.swift
//  
//
//  Created by Dariusz Grzeszczak on 22/04/2021.
//

#if canImport(SwiftUI) && canImport(Combine)
import Combine
import SwiftUI
import ReMVVMCore

extension ReMVVM {
/**
 A property wrapper that serves Dispatcher object

 ##Example

 ```
 struct DetailsView: View {

     @ReMVVM.Dispatcher var dispatcher

     var body: some View {
            VStack {
                Button(action: dispatcher[NumberAction.increase(by: 1)]) {
                    Text("Increase by 1")
                }
            }
     }
 }
 ```
 */

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    @propertyWrapper
    public struct Dispatcher: DynamicProperty, ReMVVMCore.Dispatcher {

        @Environment(\.remvvmConfig) private var remvvmConfig
        private var userProvidedStore: AnyStore?
        private var wrapper: Wrapper

        /// Dispatcher object that can be used for Action dispatch
        public var wrappedValue: ReMVVMCore.Dispatcher { wrapper } 

        /// Initializes property wrapper
        /// - Parameter store: user provided store that will be used intsted of ReMVVM provided
        public init(store: AnyStore? = nil) {
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

        /// Dishpatches an action.
        /// - Parameter action: action to dispach
        public func dispatch(action: StoreAction, log: Logger.Info) {
            wrappedValue.dispatch(action: action, log: log)
        }

        private class Wrapper: StoreUpdatableBase<Any>, ReMVVMCore.Dispatcher {

            func dispatch(action: StoreAction, log: Logger.Info) {
                store.dispatch(action: action, log: log)
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ReMVVM.Dispatcher: StoreUpdatable {
    func update(store:  AnyStore) {
        wrapper.update(store: store)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ReMVVM.Dispatcher: ReMVVMConfigProvider {
    var userProvidedConfig: ReMVVMConfig? {
        guard let userProvidedStore = userProvidedStore else { return nil }
        return ReMVVMConfig(store: userProvidedStore)
    }

    var config: ReMVVMConfig { userProvidedConfig ?? remvvmConfig }
}
#endif
