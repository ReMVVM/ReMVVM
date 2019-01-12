//
//  GreetingsViewModel.swift
//  ReMVVMBasicExample
//
//  Created by Dariusz Grzeszczak on 11/01/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import RxSwift

struct GreetingsViewModel {
    let messageLabel: Observable<String>

    init(with user: User) {
        messageLabel = .just("Hello \(user.firstName) \(user.lastName) <3")
    }
}
