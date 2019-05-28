//
//  LoginViewController.swift
//  ReMVVMBasicExample
//
//  Created by Dariusz Grzeszczak on 10/01/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import UIKit
import ReMVVM
import RxCocoa
import RxSwift

class LoginViewController: UIViewController, ReMVVMDriven {

    @IBOutlet private var firstNameTextField: UITextField!
    @IBOutlet private var lastNameTextField: UITextField!

    @IBOutlet private var loginButton: UIButton!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // get view model
        guard let viewModel: LoginViewModel = remvvm.viewModel(for: self) else { return }

        // bind view model to view
        viewModel.firstName.bind(to: firstNameTextField.rx.text).disposed(by: disposeBag)
        viewModel.lastName.bind(to: lastNameTextField.rx.text).disposed(by: disposeBag)

        // bind view to view model
        firstNameTextField.rx.text.orEmpty.bind(to: viewModel.firstName).disposed(by: disposeBag)
        lastNameTextField.rx.text.orEmpty.bind(to: viewModel.lastName).disposed(by: disposeBag)

        // handle login button tap
        // without rx: self.remvvm.dispatch(action: LoginAction(firstName: , lastName:))
        loginButton.rx.tap
            .withLatestFrom(Observable.combineLatest(viewModel.firstName, viewModel.lastName))
            .map(LoginAction.init)
            .bind(to: remvvm.rx)
            .disposed(by: disposeBag)
    }
}
