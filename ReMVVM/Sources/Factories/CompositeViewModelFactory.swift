//
//  CompositeViewModelFactory.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import MVVM

public final class CompositeViewModelFactory: ViewModelFactory {

    private var factories: [ViewModelFactory] = [InitializableViewModelFactory()]

    public init() { }

    public init(with factories: [ViewModelFactory]) {
        self.factories.append(contentsOf: factories)
    }

    public init(with factory: ViewModelFactory) {
        add(factory: factory)
    }

    public init<VM>(with factory: @escaping () -> VM) where VM: ViewModel {
        add(factory: factory)
    }

    public init<VM>(with factory: @escaping () -> VM?) where VM: ViewModel {
        add(factory: factory)
    }

    public init<VM>(with factory: @escaping (String?) -> VM?) where VM: ViewModel {
        add(factory: factory)
    }

    public func add(factory: ViewModelFactory) {
        factories.append(factory)
    }

    public func add<VM>(factory: @escaping () -> VM) where VM: ViewModel {
        factories.append(SingleViewModelFactory(with: { _ in factory() }))
    }

    public func add<VM>(factory: @escaping () -> VM?) where VM: ViewModel {
        factories.append(SingleViewModelFactory(with: { _ in factory() }))
    }

    public func add<VM>(factory: @escaping (String?) -> VM?) where VM: ViewModel {
        factories.append(SingleViewModelFactory(with: factory))
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
