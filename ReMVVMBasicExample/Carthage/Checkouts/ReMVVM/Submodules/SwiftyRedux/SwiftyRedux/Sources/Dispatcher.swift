//
//  Dispatcher.swift
//  SwiftyRedux
//
//  Created by Dariusz Grzeszczak on 10/12/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import Foundation


/// Gives the option to dishpatch actions
public protocol Dispatcher {
    /// Dishpatches action.
    /// - Parameter action: action to dispach
    func dispatch(action: StoreAction)
}

@available(*, deprecated, renamed: "Dispatcher")
public typealias StoreActionDispatcher = Dispatcher
