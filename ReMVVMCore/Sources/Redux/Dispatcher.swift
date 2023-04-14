//
//  Dispatcher.swift
//  SwiftyRedux
//
//  Created by Dariusz Grzeszczak on 10/12/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/// Object that is able to dishpatch actions
public protocol Dispatcher {
    /// Dishpatches an action.
    /// - Parameter action: action to dispach
    func dispatch(action: StoreAction, log: Logger.Info)
    
    /// Dishpatches multiple actions.
    /// - Parameter actions: action to dispach
    func dispatch(actions: [StoreAction], log: Logger.Info)
}

extension Dispatcher {
    public func dispatch(action: StoreAction, file: String = #fileID, function: String = #function, line: Int = #line) {
        self.dispatch(action: action, log: Logger.Info(file: file, function: function, line: line))
    }
    
    public func dispatch(actions: [StoreAction], file: String = #fileID, function: String = #function, line: Int = #line) {
        self.dispatch(actions: actions, log: Logger.Info(file: file, function: function, line: line))
    }
    
    public func dispatch(action: StoreAction, log: Logger.Info) {
        self.dispatch(actions: [action], log: log)
    }
}

extension Dispatcher {
    /// Subscript to create closure to dispatch
    /// - Parameter action: action to dispatch
    public subscript (_ action: @escaping @autoclosure () -> StoreAction, file: String = #fileID, function: String = #function, line: Int = #line) -> () -> Void {
        { dispatch(action: action(), log: Logger.Info(file: file, function: function, line: line)) }
    }
}
