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

class GreetingsViewController: UIViewController, ReMVVMDriven {

    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var logoutButton: UIButton!

    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()

        // handle logout button tap
        // without Rx: self.remvvm.dispatch(action: LogoutAction())
        logoutButton.rx.tap
            .map { LogoutAction() }
            .bind(to: remvvm.rx)
            .disposed(by: disposeBag)

        // get view model from remvvm and bind to the view
        guard let viewModel: GreetingsViewModel = remvvm.viewModel(for: self) else { return }
        viewModel.messageLabel.bind(to: messageLabel.rx.text).disposed(by: disposeBag)
    }
}
