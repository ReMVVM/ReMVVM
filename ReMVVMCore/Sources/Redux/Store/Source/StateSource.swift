//
//  StateSource.swift
//  SwiftyRedux
//
//  Created by Dariusz Grzeszczak on 10/12/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/// Source with current state
public protocol StateSource: StateAssociated, Source {
    /// Current state value
    var state: State { get }
}

///// Source with optional current state
//public protocol OptionalStateSource: StateAssociated, Source {
//    /// Current state value
//    var state: State? { get }
//}
