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

     @SourcedDispatcher var dispatcher

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

        public init(store: AnyStore? = nil) {
            userProvidedStore = store
            if let userProvidedStore = userProvidedStore { // do not update store when provided by user
                wrapper = .init(store: userProvidedStore)
            } else {
                wrapper = .init(store: ReMVVMConfig.empty.store)
                wrapper.update(store: remvvmConfig.store)
            }
        }

        public func update() {
            if userProvidedStore == nil { // do not update store when provided by user
                wrapper.update(store: remvvmConfig.store)
            }
        }

        public func dispatch(action: StoreAction) {
            wrappedValue.dispatch(action: action)
        }

        private class Wrapper: StoreUpdatableBase<Any>, ReMVVMCore.Dispatcher {

            func dispatch(action: StoreAction) {
                store.dispatch(action: action)
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
