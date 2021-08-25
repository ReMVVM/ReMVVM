//
//  ViewModelFactory.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

/// Factory that creates view models
public protocol ViewModelFactory {
    /// Returns true if is able to create view model of specified type
    /// - Parameter type: view model's type to be created
    func creates<VM: ViewModel>(type: VM.Type) -> Bool
    /// Creates view model of specified type or returns nil if is not able
    /// - Parameter key: optional identifier
    func create<VM: ViewModel>(key: String?) -> VM?
}
