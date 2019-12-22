//
//  SingleViewModelFactory.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import MVVM

/**
 Creates view models based on closure given in initializer.

 #Example
 ```
    let factory = SingleViewModelFactory { return LoginViewModel(username: username) }
 ```
 */
public struct SingleViewModelFactory<SVM: ViewModel>: ViewModelFactory {

    private let factory: (String?) -> SVM?

    /// Initializes factory with closure
    /// - Parameter factory: closure factory that will be used to create view model
    public init(with factory: @escaping (String?) -> SVM?) {
        self.factory = factory
    }

    /// Returns true if is able to create view model of specified type
    /// - Parameter type: view model's type to be created
    public func creates<VM: ViewModel>(type: VM.Type) -> Bool {
        guard type == SVM.self else { return false }
        return true
    }

    /// Creates view model of specified type or returns nil if is not able
    /// - Parameter key: optional identifier
    public func create<VM: ViewModel>(key: String?) -> VM? {
        guard creates(type: VM.self) else { return nil }
        return factory(key) as? VM
    }
}
