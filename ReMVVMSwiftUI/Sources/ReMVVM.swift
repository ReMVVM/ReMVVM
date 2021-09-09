//
//  File.swift
//  
//
//  Created by Dariusz Grzeszczak on 20/08/2021.
//

import Foundation
import ReMVVMCore

public typealias Initializable = ReMVVMCore.Initializable
public typealias StateObserver = ReMVVMCore.StateObserver
public typealias Store = ReMVVMCore.Store
public typealias AnyStore = ReMVVMCore.AnyStore
public typealias Reducer = ReMVVMCore.Reducer
public typealias Middleware = ReMVVMCore.Middleware
public typealias StateMapper = ReMVVMCore.StateMapper
public typealias MockSource = ReMVVMCore.MockSource

//todo add rest
//todo exension initialize instead of ReMVVMExtension AND CHANGE ORDER TO THE SAME AS STORE



public enum ReMVVM {
    /// Initialize ReMVVM with the store. By default .empty store is used.
    public static func initialize<State: StoreState>(with store: Store<State>) {
        ReMVVMCore.ReMVVM.initialize(with: store)
    }
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
