//
//  StateAssociated.swift
//  SwiftyRedux
//
//  Created by Dariusz Grzeszczak on 10/12/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/// Associate object with the State
public protocol StateAssociated {

    /// State type associated with the object
    associatedtype State
}
