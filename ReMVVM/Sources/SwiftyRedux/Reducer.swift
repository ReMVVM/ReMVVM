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
    associatedtype Action: StoreAction
    /// type of state handled by this Reducer
    associatedtype State

    /// Pure function that returns new state based on current state and the action
    /// - Parameters:
    ///   - state: current state
    ///   - action: action used for creating new state
    static func reduce(state: State, with action: Action) -> State
}

extension Reducer {

    /// Returns type erasured reducer
    public static var any: AnyReducer<State> { return AnyReducer(reducer: self) }
}

/**
 Type erasured reducer. Used to make composition of pure reducers into more complicated state reducers.

 #Examples

 - Convert Reducer to AnyReducer
    ```
    let anyLoginReducer = LoginReducer.any // AnyReducer<UserState>
    ```

 - Compose reducers for the same State
    ```
    let userReducer = AnyReducer(with: [LoginReducer.any, LogoutReducer.any]) // AnyReducer<UserState>
    ```

 - Create reducer for complex state that contains couple of 'subStates'
    ```
     let applicationReducer = AnyReducer { state, action -> ApplicationState in

        let userReducer = AnyReducer(with: [LoginReducer.any, LogoutReducer.any])
        // ...
        return ApplicationState(
             userState: userReducer.reduce(state: state.userState, with: action),
             favouritesState: favouriteReducer.reduce(state: state.favouritesState, with: action),

            // ...
        )
     }
    ```
 */
public struct AnyReducer<State> {

    private var reducer: (_ state: State, _ action: StoreAction) -> State

    init<Action, R: Reducer>(reducer: R.Type) where R.Action == Action, R.State == State {
        self.reducer = { state, action in
            guard type(of: action) == Action.self, let action = action as? Action else { return state }
            return reducer.reduce(state: state, with: action)
        }
    }

    /// Initialize reducer with an array of reducers to compose
    /// - Parameter reducers: array of reducers to compose
    public init(with reducers: [AnyReducer<State>]) {
        self.reducer = { state, action in
            return reducers.reduce(state) { state, reducer in
                return reducer.reduce(state: state, with: action)
            }
        }
    }

    /// Initialize reducer with pure function
    /// - Parameter reducer: pure function that will be used to reduce state
    public init(reducer: @escaping (_ state: State, _ action: StoreAction) -> State) {
        self.reducer = reducer
    }

    /// Reduce the state - returns new state base on current state and action.
    /// - Parameters:
    ///   - state: current state to reduce
    ///   - action: action
    public func reduce(state: State, with action: StoreAction) -> State {
        return self.reducer(state, action)
    }
}

/// Reducer that doesn't change the state.
public struct EmptyReducer<Action: StoreAction, State>: Reducer {

    /// Returns not changed state.
    /// - Parameters:
    ///   - state: current state to reduce
    ///   - action: actiono
    public static func reduce(state: State, with action: Action) -> State {
        return state
    }
}
