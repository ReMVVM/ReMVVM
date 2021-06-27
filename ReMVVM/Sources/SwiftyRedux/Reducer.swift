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


    /// Combine reducer with other reducer for the same State type.
    /// - Parameters:
    ///   - reducer: reducer to combine with
    public static func combine<R>(_ reduce: R.Type) -> CombinedReducer<Self, R>.Type  where R: Reducer, State == R.State {
        return CombinedReducer<Self, R>.self
    }
}

/** Reducer that combines other reducers for the same state but different Actions

 #Example

 public enum NavigationReducer: Reducer {

     static let combined = PushReducer
         .combine(PopReducer.self)
         .combine(ShowReducer.self)

     public static func reduce(state: Navigation, with action: StoreAction) -> Navigation {
         return combined.reduce(state: state, with: action)
     }
 }
 */
public enum CombinedReducer<R1, R2>: Reducer where R1: Reducer, R2: Reducer, R1.State == R2.State  {

    /// Pure function that returns new state based on current state and the action
    /// - Parameters:
    ///   - state: current state
    ///   - action: action used for creating new state
    public static func reduce(state: R1.State, with action: StoreAction) -> R1.State {
        let state = R1.reduce(state: state, with: action)
        return R2.reduce(state: state, with: action)
    }
}

/// Reducer that doesn't change the state.
public enum EmptyReducer<Action: StoreAction, State>: Reducer {

    /// Returns not changed state.
    /// - Parameters:
    ///   - state: current state to reduce
    ///   - action: actiono
    public static func reduce(state: State, with action: Action) -> State {
        return state
    }
}
