//
//  Source.swift
//  SwiftyRedux
//
//  Created by Dariusz Grzeszczak on 10/12/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/// Describes a source that can be used to observe state changes
public protocol Source {
    /// Adds state observer
    /// - Parameter observer: observer to be notified on state changes
    func add<Observer>(observer: Observer) where Observer: StateObserver

    /// Removes state observer
    /// - Parameter observer: observer to remove
    func remove<Observer>(observer: Observer) where Observer: StateObserver
}
