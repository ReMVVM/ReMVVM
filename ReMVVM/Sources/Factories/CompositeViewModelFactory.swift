//
//  CompositeViewModelFactory.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import MVVM

/**
 ViewModelFactory that is composition of other factories. By default creates view models with empty constructor ie. Initializable view models.

 ##Example

 ```
 let factory = CompositeViewModelFactory() // creates all Initializable view models
 factory.add { LoginViewModel(userName: userName) } // creates LoginViewModel
 factory.add { key -> BookListViewModel? in // creates BookListViewModel based on specified key
    switch key {
    case "favourites": return BookListViewModel(data: favourites)
    case "popular": return BookListViewModel(data: popular)
    default: return nil
    }
 }
 ```
 */
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

    /// Initialize factory with factory method
    /// - Parameter factory: factory method that has to be added
    public init<VM>(with factory: @escaping () -> VM) where VM: ViewModel {
        add(factory: factory)
    }

    /// Initialize factory with factory method
    /// - Parameter factory: factory method that has to be added
    public init<VM>(with factory: @escaping () -> VM?) where VM: ViewModel {
        add(factory: factory)
    }

    /// Initialize factory with factory method
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
    /// - Parameter key: optional identifier
    public func create<VM: ViewModel>(key: String?) -> VM? {
        for factory in factories {
            if let viewModel: VM = factory.create(key: key) {
                return viewModel
            }
        }
        return nil
    }
}
