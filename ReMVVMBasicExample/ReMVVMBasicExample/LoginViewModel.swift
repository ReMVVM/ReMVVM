//
//  LoginViewModel.swift
//  ReMVVMBasicExample
//
//  Created by Dariusz Grzeszczak on 11/01/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVM
import RxSwift

final class LoginViewModel: StoreSubscriber, Initializable {
    let firstName = BehaviorSubject(value: "")
    let lastName = BehaviorSubject(value: "")

    func didChange(state: AppState, oldState: AppState) {
        if oldState.user != nil && state.user == nil {
            // reset values on logout
            firstName.onNext("")
            lastName.onNext("")
        }
    }
}
