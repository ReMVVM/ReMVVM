//
//  CompositeViewModelFactory.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import MVVM

public struct CompositeStoreViewModelFactory: ViewModelFactory {

    private var factories: [ViewModelFactory] = []

    public init() { }
    public init(factory: ViewModelFactory) {
        add(factory: factory)
    }
    public init<VM>(factory: @escaping () -> VM) where VM: ViewModel {
        add(factory: factory)
    }

    public init<VM>(factory: @escaping (String?) -> VM?) where VM: ViewModel {
        add(factory: factory)
    }

    public mutating func add(factory: ViewModelFactory) {
        factories.append(factory)
    }

    public mutating func add<VM>(factory: @escaping () -> VM) where VM: ViewModel {
        factories.append(SingleViewModelFactory(factory: { _ in factory() }))
    }

    public mutating func add<VM>(factory: @escaping (String?) -> VM?) where VM: ViewModel {
        factories.append(SingleViewModelFactory(factory: factory))
    }

    public func creates<VM: ViewModel>(type: VM.Type) -> Bool {
        return factories.contains { $0.creates(type: type) }
    }

    public func create<VM: ViewModel>(key: String?) -> VM? {
        for factory in factories {
            if let viewModel: VM = factory.create(key: key) {
                return viewModel
            }
        }
        return nil
    }
}
