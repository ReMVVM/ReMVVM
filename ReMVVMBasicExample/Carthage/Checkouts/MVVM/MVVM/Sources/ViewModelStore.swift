//
//  ViewModelStore.swift
//  MVVM
//
//  Created by Dariusz Grzeszczak on 19/05/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public final class ViewModelStore {
    private var store = [String: ViewModel]()

    func put(viewModel: ViewModel, for key: String) {
        store[key] = viewModel
    }

    func viewModel(for key: String) -> ViewModel? {
        return store[key]
    }

    public func clear() {
        store = [:]
    }
}
