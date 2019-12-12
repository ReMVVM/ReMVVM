//
//  LoginAction.swift
//  ReMVVMBasicExample
//
//  Created by Dariusz Grzeszczak on 11/01/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVM

struct LoginAction: StoreAction {
    let firstName: String
    let lastName: String
}

struct LoginReducer: Reducer {

    static func reduce(state: AppState, with action: LoginAction) -> AppState {
        let user = User(firstName: action.firstName, lastName: action.lastName)
        return AppState(factory: state.factory, user: user)
    }
}

struct LoginMiddleware: Middleware {
    let uiState: UIState

    func applyMiddleware(for state: AppState, action: LoginAction, dispatcher: Dispatcher<LoginAction, AppState>) {

        // here you can do something asynchronously - like download user data
        // ....

        dispatcher.next { state in
            // this closure is called after action is handled by reducer - can be used for side effects like that ;)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LogoutViewController")
            self.uiState.showModal(controller: controller)
        }
    }
}
