//
//  InitializableViewModelFactory.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 18/08/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import MVVM

/// Initializable type that require to provide empty constructor
public typealias Initializable = MVVM.Initializable

/// Helper implementation of view model factory that creates view models with empty constructor (Initializable view models)
public struct InitializableViewModelFactory: ViewModelFactory {

    private let viewModelFactory = MVVM.InitializableViewModelFactory()

    public init() { }

    public func creates<VM>(type: VM.Type) -> Bool {
        return type is Initializable.Type
    }

    public func create<VM>(key: String?) -> VM? {
        return viewModelFactory.create()
    }
}
