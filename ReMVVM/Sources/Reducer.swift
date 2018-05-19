//
//  Reducer.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public protocol Reducer {
    associatedtype StoreAction: Action
    associatedtype StoreState: State

    static func reduce(state: StoreState, with params: StoreAction.ParamType) -> StoreState
}
