//
//  AnyStateStore.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

protocol AnyStateSource: Dispatcher, Source, AnyObject {
    var anyState: Any { get }
    func mappedState<NewState>() -> NewState?
}
