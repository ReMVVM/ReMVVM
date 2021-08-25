//
//  ViewModelStores.swift
//  MVVM
//
//  Created by Dariusz Grzeszczak on 01/10/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

final class ViewModelStores {
    static func store(for context: ViewModelContext) -> ViewModelStore {
        if let existing = context.viewModelStore {
            return existing
        } else {
            let store = ViewModelStore()
            context.viewModelStore = store
            return store
        }
    }
}
