//
//  Typealiases.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 01/10/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import MVVM
import SwiftyRedux

public typealias ViewModel = MVVM.ViewModel
public typealias ViewModelContext = MVVM.ViewModelContext

public typealias Store<State> = SwiftyRedux.Store<State> where State: StoreState
public typealias StoreAction = SwiftyRedux.StoreAction
public typealias Reducer = SwiftyRedux.Reducer
public typealias AnyMiddleware = SwiftyRedux.AnyMiddleware
public typealias Middleware = SwiftyRedux.Middleware
public typealias Dispatcher = SwiftyRedux.Dispatcher
public typealias StoreSubscriber = SwiftyRedux.StoreSubscriber
public typealias StoreActionDispatcher = SwiftyRedux.StoreActionDispatcher
