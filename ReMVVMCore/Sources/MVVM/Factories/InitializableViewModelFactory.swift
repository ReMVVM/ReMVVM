//
//  InitializableViewModelFactory.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 18/08/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//


/// ViewModelFactory that creates view models using empty constructor (Initializable view models)
public final class InitializableViewModelFactory: ViewModelFactory {

    /// Initializes factory
    public init() { }

    /// Returns true if is able to create view model of specified type
    /// - Parameter type: view model's type to be created
    public func creates<VM>(type: VM.Type) -> Bool {
        return type is Initializable.Type
    }

    /// Creates view model of specified type or returns nil if is not able
    /// - Parameter key: optional identifier
    public func create<VM>(key: String?) -> VM? {
        guard let objType = VM.self as? (Initializable.Type) else { return nil }
        return objType.init() as? VM
    }
}
