//
//  LogoutAction.swift
//  ReMVVMBasicExample
//
//  Created by Dariusz Grzeszczak on 11/01/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVM

struct LogoutAction: StoreAction { }

struct LogoutReducer: Reducer {
    static func reduce(state: AppState, with action: LogoutAction) -> AppState {
        return AppState(factory: state.factory, user: nil)
    }
}

struct LogoutMiddleware: Middleware {
    let uiState: UIState

    func applyMiddleware(for state: AppState, action: LogoutAction, dispatcher: Dispatcher<LogoutAction, AppState>) {

        dispatcher.next { state in
            self.uiState.dismissModal()
        }
    }
}
