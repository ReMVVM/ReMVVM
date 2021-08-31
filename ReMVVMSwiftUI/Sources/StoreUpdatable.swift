//
//  File.swift
//  
//
//  Created by Dariusz Grzeszczak on 27/08/2021.
//

import Foundation
import ReMVVMCore

protocol ReMVVMConfigProvider {
    var config: ReMVVMConfig { get }
}

protocol StoreUpdatable {
    func update(store: AnyStore)
}

class StoreUpdatableBase<State>: StoreUpdatable {

    var store: Store<State?>
    var anyStore: AnyStore

    init(store: AnyStore) {
        self.anyStore = store
        self.store = store.mapped()
    }

    func update(store: AnyStore) {
        guard store !== self.anyStore else { return }
        self.anyStore = store
        self.store = store.mapped()
        storeChanged()
    }

    func storeChanged() { }
}
