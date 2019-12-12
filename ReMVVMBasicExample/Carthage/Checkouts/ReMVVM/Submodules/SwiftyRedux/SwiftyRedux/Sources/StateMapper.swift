//
//  StateMapper.swift
//  SwiftyRedux
//
//  Created by Dariusz Grzeszczak on 10/12/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/// Maps application state to any 'sub'state that may be observed in the store.
public struct StateMapper<State> {

    let newStateType: Any.Type
    private let _map: (State) -> Any
    /// Initialize mapper with map finction
    /// - Parameter map: pure function that maps the state to 'sub'state
    public init<NewState>(map: @escaping (State) -> NewState) {
        newStateType = NewState.self
        _map = { map($0) }
    }

    func matches<State>(state: State.Type) -> Bool {
        return newStateType == state
    }

    func map<NewState>(state: State) -> NewState? {
        guard newStateType == NewState.self else { return nil }
        return _map(state) as? NewState
    }
}
