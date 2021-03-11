//
//  InitializableViewModelFactory.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 18/08/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import MVVM

/// Requires empty constructor
public typealias Initializable = MVVM.Initializable

/// ViewModelFactory that creates view models using empty constructor (Initializable view models)
public struct InitializableViewModelFactory: ViewModelFactory {

    private let viewModelFactory = MVVM.InitializableViewModelFactory()

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
        return viewModelFactory.create()
    }
}

@available(*, deprecated, renamed: "StateSourceInitializable")
public typealias StateSubjectInitializable = StateSourceInitializable

public protocol StateSourceInitializable: StateAssociated, Initializable {
    associatedtype State = State

    init(with source: AnyStateSource<State>)
}

extension StateSourceInitializable {

    public init() {
        self.init(with: AnyStateSource<State>.store)
    }

    public init(mock state: State) {
        self.init(with: .mock(state))
    }
}


