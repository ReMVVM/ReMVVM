//
//  File.swift
//  
//
//  Created by Dariusz Grzeszczak on 20/08/2021.
//

import Foundation

extension ReMVVM {

    @propertyWrapper
    public final class Dispatcher: ReMVVMCore.Dispatcher {

        /// wrapped value of view model
        public lazy var wrappedValue: ReMVVMCore.Dispatcher = ReMVVMConfig.shared.store

        /// Initializes property wrapper
        public init()  { }

        public func dispatch(action: StoreAction) {
            wrappedValue.dispatch(action: action)
        }
    }
}
