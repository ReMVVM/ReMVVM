//
//  CompositeViewModelFactory.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import MVVM

/// Helper implementation of view model factory that is composite of many simple factories. By default creates view models with empty constructor ie. Initializable view models.
public final class CompositeViewModelFactory: ViewModelFactory {

    private var factories: [ViewModelFactory] = [InitializableViewModelFactory()]

    /// Initialize empty factory that creates Initializable view models. Other factories may be added by add() method.
    public init() { }

    /// Initialize factory with other factories
    /// - Parameter factories: factories to be used
    public init(with factories: [ViewModelFactory]) {
        self.factories.append(contentsOf: factories)
    }

    /// Initialize factory with other factory.
    /// - Parameter factory: factory to be used
    public init(with factory: ViewModelFactory) {
        add(factory: factory)
    }

    /// Initialize factory with simple factory method
    /// - Parameter factory: factory method that has to be added
    public init<VM>(with factory: @escaping () -> VM) where VM: ViewModel {
        add(factory: factory)
    }

    /// Initialize factory with simple factory method
    /// - Parameter factory: factory method that has to be added
    public init<VM>(with factory: @escaping () -> VM?) where VM: ViewModel {
        add(factory: factory)
    }

    /// Initialize factory with simple factory method
    /// - Parameter factory: factory method that has to be added
    public init<VM>(with factory: @escaping (String?) -> VM?) where VM: ViewModel {
        add(factory: factory)
    }

    /// Adds factory to composite view model factory
    /// - Parameter factory: factory to be added
    public func add(factory: ViewModelFactory) {
        factories.append(factory)
    }

    /// Adds factory to composite view model factory
    /// - Parameter factory: factory to be added
    public func add<VM>(factory: @escaping () -> VM) where VM: ViewModel {
        factories.append(SingleViewModelFactory(with: { _ in factory() }))
    }

    /// Adds factory to composite view model factory
    /// - Parameter factory: factory to be added
    public func add<VM>(factory: @escaping () -> VM?) where VM: ViewModel {
        factories.append(SingleViewModelFactory(with: { _ in factory() }))
    }

    /// Adds factory to composite view model factory
    /// - Parameter factory: factory to be added
    public func add<VM>(factory: @escaping (String?) -> VM?) where VM: ViewModel {
        factories.append(SingleViewModelFactory(with: factory))
    }

    /// Returns true if is able to create view model of specified type
    /// - Parameter type: view model's type to be created
    public func creates<VM: ViewModel>(type: VM.Type) -> Bool {
        return factories.contains { $0.creates(type: type) }
    }

    /// Creates view model of specified type or returns nil if is not able
    /// - Parameter key: view model's type to be created
    public func create<VM: ViewModel>(key: String?) -> VM? {
        for factory in factories {
            if let viewModel: VM = factory.create(key: key) {
                return viewModel
            }
        }
        return nil
    }
}
