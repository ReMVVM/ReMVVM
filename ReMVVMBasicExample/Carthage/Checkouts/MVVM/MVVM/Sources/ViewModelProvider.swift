//
//  ViewModelProvider.swift
//  MVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public final class ViewModelProvider {

    private let factory: ViewModelFactory
    private var store: ViewModelStore

    init(with store: ViewModelStore, factory: ViewModelFactory) {
        self.store = store
        self.factory = factory
    }

    private let defaultKeyPrefix = "com.db.vmp."
    public func get<VM: ViewModel>(for key: String? = nil) -> VM? {
        let key = key ?? defaultKeyPrefix + String(describing: VM.self)
        if let created = store.viewModel(for: key) as? VM {
            return created
        }

        guard let viewModel: VM = factory.create() else { return nil }
        store.put(viewModel: viewModel, for: key)
        return viewModel
    }
}
