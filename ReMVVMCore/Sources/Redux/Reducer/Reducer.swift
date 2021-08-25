//
//  Reducer.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/**
 Provides pure function that creates new state based on the action and current state. It is associated with specific Action type.

 #Example
     struct LoginReducer: Reducer {

         static func reduce(state: AppState, with action: LoginAction) -> AppState {
             let user = User(firstName: action.firstName, lastName: action.lastName)
             return AppState(factory: state.factory, user: user)
         }
     }
 */
public protocol Reducer {
    /// type of action handled by this Reducer
    associatedtype Action//: StoreAction
    /// type of state handled by this Reducer
    associatedtype State

    /// Pure function that returns new state based on current state and the action
    /// - Parameters:
    ///   - state: current state
    ///   - action: action used for creating new state
    static func reduce(state: State, with action: Action) -> State
}

extension Reducer {

    /// Default reduce function implementation for any StoreAction
    /// - Parameters:
    ///   - state: current state
    ///   - action: action used for creating new state
    public static func reduce(state: State, with action: StoreAction) -> State {
        guard Action.self == StoreAction.self || Action.self == type(of: action)
        else { return state }

        return reduce(state: state, with: action as! Action)
    }
}
