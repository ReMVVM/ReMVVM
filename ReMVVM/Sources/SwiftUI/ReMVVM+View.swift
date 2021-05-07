//
//  ReMVVM+View.swift
//  
//
//  Created by Dariusz Grzeszczak on 22/04/2021.
//

#if swift(>=5.1) && canImport(SwiftUI) && canImport(Combine)

import SwiftUI
import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {

    /// Sets up the ReMVVM source
    /// - parameter store: store that will be used for the source
    public func source<Base>(with store: Store<Base>) -> some View where Base: StoreState {
        self.environment(\.storeContainer, StoreAndViewModelProvider(store: store))
    }

    /// Sets up the ReMVVM source
    /// - parameter dispatcher: whoose store that will be used for the source
    public func source(from dispatcher: SourcedDispatcher) -> some View {
        return self.environment(\.storeContainer, dispatcher.storeContainer)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct StoreEnvKey: EnvironmentKey {
    static var defaultValue: StoreAndViewModelProvider { ReMVVM<Any>.storeContainer }
}


@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    var storeContainer: StoreAndViewModelProvider {
        get {
            self[StoreEnvKey.self]
        }
        set {
            self[StoreEnvKey.self] = newValue
        }
    }
}
#endif
