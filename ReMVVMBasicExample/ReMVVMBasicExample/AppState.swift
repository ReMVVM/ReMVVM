//
//  AppState.swift
//  ReMVVMBasicExample
//
//  Created by Dariusz Grzeszczak on 11/01/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVM
import UIKit

struct AppState: StoreState {
    let factory: ViewModelFactory

    let user: User?
}

struct User {
    let firstName: String
    let lastName: String
}

struct UIState {

    private let rootViewController: UIViewController

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }

    func showModal(controller: UIViewController) {
        rootViewController.present(controller, animated: true, completion: nil)
    }

    func dismissModal() {
        rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
    }
}
