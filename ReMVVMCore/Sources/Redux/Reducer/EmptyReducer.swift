//
//  EmpyReducer.swift
//  
//
//  Created by Dariusz Grzeszczak on 06/08/2021.
//

import Foundation

/// Reducer that doesn't change the state.
public enum EmptyReducer<Action, State>: Reducer {

    /// Returns not changed state.
    /// - Parameters:
    ///   - state: current state to reduce
    ///   - action: actiono
    public static func reduce(state: State, with action: Action) -> State {
        return state
    }
}
