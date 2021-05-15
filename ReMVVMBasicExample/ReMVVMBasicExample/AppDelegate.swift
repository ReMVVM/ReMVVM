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

        let middleware: [AnyMiddlewareConvertible] = [LoginMiddleware(uiState: uiState), LogoutMiddleware(uiState: uiState)]
        let reducer = AnyReducer(with: [LoginReducer.any, LogoutReducer.any])

        let store = Store(with: initialState, reducer: reducer, middleware: middleware)

        //factory.add { LoginViewModel() } - not needed LoginViewModel is Initializable
        factory.add { () -> GreetingsViewModel? in
            guard let user = store.state.user else { return nil }
            return GreetingsViewModel(with: user)
        }
        
        ReMVVM.initialize(with: store)

        return true
    }
}

