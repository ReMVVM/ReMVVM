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
public struct SourcedObservedObject<Obj>: DynamicProperty where Obj: ObservableObject {

    @Environment(\.storeContainer) private var storeContainer

    class Wrapper: EmptyStoreUpdatable, ObservableObject {

        private let _objectWillChange = ObservableObjectPublisher()
        var objectWillChange: Obj.ObjectWillChangePublisher { _objectWillChange as! Obj.ObjectWillChangePublisher}

        var wrappedValue: Obj {
            get { object.wrappedValue }
            set { object.wrappedValue = newValue } // TODO check update is needed ? 
        }

        var projectedValue: ObservedObject<Obj>.Wrapper { object.projectedValue }

        var object: ObservedObject<Obj>

        init(store: Dispatcher & Source & AnyStateProvider, object: Obj) {
            self.object = .init(wrappedValue: object)
            super.init(store: store)
            updateObject(object: self.object)
        }

        override func storeChanged() {
            updateObject(object: object)
        }

        private var cancellable: Cancellable?
        private func updateObject(object: ObservedObject<Obj>) {

            cancellable = nil

            let mirror = Mirror(reflecting: object.wrappedValue)
            for child in mirror.children {
                if let updatable = child.value as? StoreUpdatable {
                    updatable.update(store: store)
                }
            }

            cancellable = object.wrappedValue.objectWillChange.sink { [unowned _objectWillChange] _ in
                _objectWillChange.send()
            }
        }
    }

    @ObservedObject private var wrapper: Wrapper

    public var wrappedValue: Obj  {
        get { wrapper.wrappedValue }
        set { wrapper.wrappedValue = newValue }
    }

    public var projectedValue: ObservedObject<Obj>.Wrapper { wrapper.projectedValue }

    public mutating func update() {
        wrapper.update(store: storeContainer.store)
    }

    public init(wrappedValue: Obj) {
        wrapper = .init(store: StoreAndViewModelProvider.empty.store, object: wrappedValue)
        wrapper.update(store: storeContainer.store)
    }
}

#endif
