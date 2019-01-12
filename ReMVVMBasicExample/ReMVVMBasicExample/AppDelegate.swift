//
//  AppDelegate.swift
//  ReMVVMBasicExample
//
//  Created by Dariusz Grzeszczak on 10/01/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import UIKit
import ReMVVM

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        guard let rootViewController = window?.rootViewController else { fatalError("Root controler wasn't set") }
        let uiState = UIState(rootViewController: rootViewController)

        var getUser: (() -> User?)!
        let factory = CompositeViewModelFactory { _ -> GreetingsViewModel? in
            guard let user = getUser() else { return nil }
            return GreetingsViewModel(with: user)
        }

        let initialState = AppState(factory: factory, user: nil)
        let middleware: [AnyMiddleware] = [LoginMiddleware(uiState: uiState), LogoutMiddleware(uiState: uiState)]

        let store = Store<AppState>(with: initialState, middleware: middleware)
        store.register(reducer: LoginReducer.self)
        store.register(reducer: LogoutReducer.self)

        getUser = { store.state.user }
        
        ReMVVM.Config.initialize(with: store)

        return true
    }
}

