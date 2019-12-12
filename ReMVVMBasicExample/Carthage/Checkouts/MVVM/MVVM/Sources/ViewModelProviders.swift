//
//  ViewModelProviders.swift
//  MVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public final class ViewModelProviders {

    public static func provider(for context: ViewModelContext, with factory: ViewModelFactory = InitializableViewModelFactory()) -> ViewModelProvider {
        return ViewModelProvider(with: ViewModelStores.store(for: context), factory: factory)
    }
}
