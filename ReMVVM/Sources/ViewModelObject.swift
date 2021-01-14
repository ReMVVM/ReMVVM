//
//  File.swift
//  
//
//  Created by Dariusz Grzeszczak on 01/12/2020.
//
#if swift(>=5.1) && canImport(SwiftUI)
import Foundation
import SwiftUI

@available(iOS 13.0, *)
@propertyWrapper
public struct ViewModelObject<VM>: DynamicProperty where VM: ViewModel, VM: ObservableObject {

    @ObservedObject private var _wrappedValue: VM
    public var wrappedValue: VM {
        get { _wrappedValue }
        set { _wrappedValue = newValue }
    }

//    /// Initializes property wrapper
//    /// - Parameter key: optional identifier that will be used to create view model by ViewModelProvider
//    public init(defaultValue: @escaping @autoclosure () -> VM, key: String) {
//        _wrappedValue = Provided(key: key).wrappedValue ?? defaultValue()
//    }
//
//    /// Initializes property wrapper with no key
//    public init(defaultValue: @escaping @autoclosure () -> VM) {
//        _wrappedValue = Provided().wrappedValue ?? defaultValue()
//    }

    /// Initializes property wrapper
    /// - Parameter key: optional identifier that will be used to create view model by ViewModelProvider
    public init(wrappedValue: VM? = nil, defaultValue: @escaping @autoclosure () -> VM, key: String) {
        _wrappedValue = wrappedValue ?? Provided(key: key).wrappedValue ?? defaultValue()
    }

    /// Initializes property wrapper with no key
    public init(wrappedValue: VM? = nil, defaultValue: @escaping @autoclosure () -> VM) {
        _wrappedValue = wrappedValue ?? Provided().wrappedValue ?? defaultValue()
    }

    public init(wrappedValue: VM) {
        _wrappedValue = wrappedValue
    }

    public var projectedValue: ObservedObject<VM>.Wrapper { $_wrappedValue }


}

@available(iOS 13.0, *)
extension ViewModelObject where VM: Initializable {
    public init(key: String) {
        _wrappedValue = Provided(key: key).wrappedValue ?? VM()
    }

    public init() {
        _wrappedValue = Provided().wrappedValue ?? VM()
    }
}
#endif
