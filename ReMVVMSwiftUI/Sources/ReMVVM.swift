//
//  File.swift
//  
//
//  Created by Dariusz Grzeszczak on 20/08/2021.
//

import Foundation
import ReMVVMCore

//MVVM
public typealias CompositeViewModelFactory = ReMVVMCore.CompositeViewModelFactory
public typealias Initializable = ReMVVMCore.Initializable
public typealias InitializableViewModelFactory = ReMVVMCore.InitializableViewModelFactory
public typealias SingleViewModelFactory = ReMVVMCore.SingleViewModelFactory

public typealias ViewModel = ReMVVMCore.ViewModel
public typealias ViewModelFactory = ReMVVMCore.ViewModelFactory
public typealias ViewModelProvider = ReMVVMCore.ViewModelProvider

//Redux
public typealias AnyMiddleware = ReMVVMCore.AnyMiddleware
public typealias ConvertMiddleware = ReMVVMCore.ConvertMiddleware
public typealias Interceptor<Action, State> = ReMVVMCore.Interceptor<Action, State>
public typealias Middleware = ReMVVMCore.Middleware

public typealias ComposedReducer<R1, R2> = ReMVVMCore.ComposedReducer<R1, R2> where R1: Reducer, R2: Reducer, R1.State == R2.State
public typealias EmptyReducer<Action, State> = ReMVVMCore.EmptyReducer<Action, State>
public typealias Reducer = ReMVVMCore.Reducer

public typealias MockSource = ReMVVMCore.MockSource
public typealias Source = ReMVVMCore.Source
public typealias StateAssociated = ReMVVMCore.StateAssociated
public typealias StateObserver = ReMVVMCore.StateObserver
public typealias StateSource = ReMVVMCore.StateSource

public typealias Store = ReMVVMCore.Store
public typealias AnyStore = ReMVVMCore.AnyStore

public typealias Dispatcher = ReMVVMCore.Dispatcher
public typealias StateMapper<State> = ReMVVMCore.StateMapper<State>
public typealias StoreAction = ReMVVMCore.StoreAction
public typealias StoreState = ReMVVMCore.StoreState









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
