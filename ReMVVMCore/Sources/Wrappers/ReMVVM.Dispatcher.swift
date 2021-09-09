//
//  File.swift
//  
//
//  Created by Dariusz Grzeszczak on 20/08/2021.
//

import Foundation

extension ReMVVM {

    /**
     A property wrapper that serves Dispatcher object.
    */
    @propertyWrapper
    public final class Dispatcher: ReMVVMCore.Dispatcher {

        /// wrapped value of view model
        public lazy var wrappedValue: ReMVVMCore.Dispatcher = ReMVVMConfig.shared.store

        /// Initializes property wrapper
        /// - Parameter dispatcher: user provided dispatcher that will be used intsted of ReMVVM provided
        public init(with dispatcher: ReMVVMCore.Dispatcher? = nil)  {
            if let dispatcher = dispatcher {
                wrappedValue = dispatcher
            }
        }

        public func dispatch(action: StoreAction) {
            wrappedValue.dispatch(action: action)
        }
    }
}
