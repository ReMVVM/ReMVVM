//
//  CompositeViewModelFactory.swift
//  MVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public struct CompositeViewModelFactory: ViewModelFactory {

    private var factories: [ViewModelFactory] = [InitializableViewModelFactory()]

    public init() { }
    public init(with factory: ViewModelFactory) {
        add(factory: factory)
    }
    public init<VM>(with factory: @escaping () -> VM) where VM: ViewModel {
        add(factory: factory)
    }

    public init(with factories: [ViewModelFactory]) {
        self.factories.append(contentsOf: factories)
    }

    public mutating func add(factory: ViewModelFactory) {
        factories.append(factory)
    }

    public mutating func add<VM>(factory: @escaping () -> VM) where VM: ViewModel {
        factories.append(SingleViewModelFactory(with: factory))
    }

    public func create<VM: ViewModel>() -> VM? {
        for factory in factories {
            if let viewModel: VM = factory.create() {
                return viewModel
            }
        }

        return nil
    }
}
