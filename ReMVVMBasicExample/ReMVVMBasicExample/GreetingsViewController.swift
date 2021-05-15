//
//  LoginViewController.swift
//  ReMVVMBasicExample
//
//  Created by Dariusz Grzeszczak on 10/01/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import UIKit
import ReMVVM
import RxSwift

class GreetingsViewController: UIViewController {

    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var logoutButton: UIButton!

    // inject view model from remvvm
    @Provided private var viewModel: GreetingsViewModel?
    @ProvidedDispatcher private var dispatcher

    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()

        // handle logout button tap
        // without Rx: self.remvvm.dispatch(action: LogoutAction())
        logoutButton.rx.tap
            .map { LogoutAction() }
            .bind(to: $dispatcher)
            .disposed(by: disposeBag)

        // bind view model to the view
        viewModel?.messageLabel.bind(to: messageLabel.rx.text).disposed(by: disposeBag)
    }
}
