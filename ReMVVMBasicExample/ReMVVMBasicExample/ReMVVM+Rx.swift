//
//  ReMVVM+Rx.swift
//  ReMVVMBasicExample
//
//  Created by Dariusz Grzeszczak on 11/01/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVM
import RxSwift
import SwiftyRedux

public extension StoreActionDispatcher where Self: ObserverType {
    public func on(_ event: Event<StoreAction>) {
        guard let action = event.element else { return }
        self.dispatch(action: action)
    }
}
extension SwiftyRedux.Store: ObserverType { }
extension ReMVVM: ObserverType { }
extension Dispatcher: ObserverType { }
extension AnyDispatcher: ObserverType { }
