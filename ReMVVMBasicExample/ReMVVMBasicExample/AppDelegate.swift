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

        let factory = CompositeViewModelFactory()
        let initialState = AppState(factory: factory, user: nil)
        let middleware: [AnyMiddleware] = [LoginMiddleware(uiState: uiState), LogoutMiddleware(uiState: uiState)]

        let store = Store(with: initialState, middleware: middleware)
        store.register(reducer: LoginReducer.self)
        store.register(reducer: LogoutReducer.self)

        let rxStore = RxStore(with: store)

        factory.add { () -> LoginViewModel? in
            return LoginViewModel(state: rxStore.state)
        }
        factory.add { () -> GreetingsViewModel? in
            guard let user = store.state.user else { return nil }
            return GreetingsViewModel(with: user)
        }
        
        ReMVVM.Config.initialize(with: store)

        return true
    }
}

