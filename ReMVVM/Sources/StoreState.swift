//
//  StoreState.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 01/10/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import SwiftyRedux

public protocol StoreState: SwiftyRedux.StoreState {
    var factory: ViewModelFactory { get }
}

public protocol AnyStore: StoreActionDispatcher {
    var anyState: StoreState { get }

    func add<Subscriber>(subscriber: Subscriber) where Subscriber: StoreSubscriber
    func remove<Subscriber>(subscriber: Subscriber) where Subscriber: StoreSubscriber
}

extension Store: AnyStore {
    public var anyState: StoreState {
        return state
    }
}
