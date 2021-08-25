//
//  File.swift
//  
//
//  Created by Dariusz Grzeszczak on 06/08/2021.
//

import Foundation

struct EmptyState: StoreState {
    var factory: ViewModelFactory = CompositeViewModelFactory()
}

private let emptyStore = Store(with: EmptyState(), reducer: EmptyReducer.self).any

extension Store where State == Any {

    static var empty: Store<Any> { emptyStore }
}
