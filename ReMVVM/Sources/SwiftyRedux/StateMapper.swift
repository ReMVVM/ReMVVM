//
//  StateMapper.swift
//  SwiftyRedux
//
//  Created by Dariusz Grzeszczak on 10/12/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/**
 Maps application state to any other 'substate' that may be observed in the store.

 #Example
     struct ApplicationState: StoreState {

        let userState: UserState
        let favouritesState: FavouritesState

        let factory: ViewModelFactory
     }

     let userStateMapper = StateMapper<ApplicationState> { $0.userState }
 */
public struct StateMapper<State> {

    let newStateType: Any.Type
    private let _map: (State) -> Any
    /// Initialize mapper with map finction
    /// - Parameter map: pure function that maps the state to 'sub'state
    public init<NewState>(map: @escaping (State) -> NewState) {
        newStateType = NewState.self
        _map = { map($0) }
    }

    /// Initialize mapper with keyPath to substate
    /// - Parameter keyPath: property key path to substate
    public init<NewState>(for keyPath: KeyPath<State, NewState>) {
        self.init { $0[keyPath: keyPath] }
    }

    /// Creates enclosing mapper
    /// - Parameter map: pure function that maps the state
    public func map<NewState>(map: @escaping (NewState) -> State) -> StateMapper<NewState> {
        StateMapper<NewState>(child: self, map: map)
    }

    /// Creates enclosing mapper
    /// - Parameter keyPath: pure function tthet maps the state
    public func map<NewState>(with keyPath: KeyPath<NewState, State>) -> StateMapper<NewState> {
        StateMapper<NewState>(child: self, map: { $0[keyPath: keyPath] })
    }

    private init<ChildState>(child: StateMapper<ChildState>, map: @escaping (State) -> ChildState) {
        newStateType = child.newStateType
        _map = { child.map(state: map($0)) }
    }

    func matches(state: Any.Type) -> Bool {
        return newStateType == state
    }

    func map(state: State) -> Any {
        _map(state)
    }

    func map<NewState>(state: State) -> NewState? {
        guard newStateType == NewState.self else { return nil }
        return map(state: state) as? NewState
    }
}
