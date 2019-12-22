//
//  StoreState.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 01/10/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

/// Application state managed by  the store. It has to provide ViewModelFactory that will be used to create view models.
public protocol StoreState {
    /// View model factory that will be used to create view models.
    var factory: ViewModelFactory { get }
}
