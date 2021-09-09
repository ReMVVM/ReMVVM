//
//  ComposedReducer.swift
//  
//
//  Created by Dariusz Grzeszczak on 06/08/2021.
//

import Foundation

/** Reducer that combines other reducers for the same State but different Actions

 #Example

 public enum NavigationReducer: Reducer {

     static let composed = PushReducer
         .compose(with: PopReducer.self)
         .compose(with: ShowReducer.self)

     public static func reduce(state: Navigation, with action: StoreAction) -> Navigation {
         return composed.reduce(state: state, with: action)
     }
 }
 */

public enum ComposedReducer<R1, R2>: Reducer where R1: Reducer, R2: Reducer, R1.State == R2.State  {

    /// Pure function that returns new state based on current state and the action
    /// - Parameters:
    ///   - state: current state
    ///   - action: action used for creating new state
    public static func reduce(state: R1.State, with action: StoreAction) -> R1.State {
        let state = R1.reduce(state: state, with: action)
        return R2.reduce(state: state, with: action)
    }
}

extension Reducer {
    /// Combine reducer with other reducer for the same State type.
    /// - Parameters:
    ///   - reducer: reducer to combine with
    public static func compose<R>(with reducer: R.Type) -> ComposedReducer<Self, R>.Type  where R: Reducer, State == R.State {
        return ComposedReducer<Self, R>.self
    }
}
