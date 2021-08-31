//
//  File.swift
//  
//
//  Created by Dariusz Grzeszczak on 20/08/2021.
//

import Foundation
import ReMVVMCore

public typealias Initializable = ReMVVMCore.Initializable
//public typealias MockSource = ReMVVMCore.MockSource

public enum ReMVVM {

}



extension Mirror {
    
    func remvvm_updateStoreUpdatableChildren(store: AnyStore) {
        for child in children {
            if let updatable = child.value as? StoreUpdatable {
                updatable.update(store: store)
            }
        }
    }
}
