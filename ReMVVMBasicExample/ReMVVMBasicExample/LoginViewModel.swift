//
//  LoginViewModel.swift
//  ReMVVMBasicExample
//
//  Created by Dariusz Grzeszczak on 11/01/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVM
import RxSwift

final class LoginViewModel: ReMVVMDriven, StoreSubscriber {
    typealias State = AppState

    let firstName = BehaviorSubject(value: "")
    let lastName = BehaviorSubject(value: "")

    private let disposeBag = DisposeBag()
    init() {
        let state = remvvm.rx.state
        state.map { $0.user?.firstName ?? "" }.bind(to: firstName).disposed(by: disposeBag)
        state.map { $0.user?.lastName ?? "" }.bind(to: lastName).disposed(by: disposeBag)
    }
}
