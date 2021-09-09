//
//  Provided.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 10/12/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//


extension ReMVVM {
/**
 A property wrapper that serves view model of specified type.

 #Example
 ```
    class GreetingsViewController: UIViewController {

     // inject view model from remvvm
     @ReMVVM.ViewModel private var viewModel: GreetingsViewModel?

     private let disposeBag = DisposeBag()
     override func viewDidLoad() {
         super.viewDidLoad()

         // bind view model to the view
         let message = viewModel?.messageLabel
         // ....
     }
    }
 ```
 */

    @propertyWrapper
    public final class ViewModel<VM: ReMVVMCore.ViewModel> {
        /// wrapped value of view model
        public private(set) lazy var wrappedValue: VM? = getViewModel()

        private let getViewModel: () -> VM?

        /// Initializes property wrapper
        /// - Parameters
        /// - key: optional identifier that will be used to create view model by ViewModelProvider
        /// - store: user provided store that will be used intsted of ReMVVM provided 
        public init(key: String? = nil, store: AnyStore? = nil) {
            getViewModel = { ReMVVMConfig.shared.viewModelProvider.viewModel(with: key) }
            if let store = store {
                wrappedValue = ViewModelProvider(with: store).viewModel(with: key)
            }
        }

        /// Initializes property wrapper
        /// - Parameters
        /// - key: optional identifier that will be used to create view model by ViewModelProvider
        /// - store: user provided store that will be used intsted of ReMVVM provided
        public init(key: String? = nil, store: AnyStore? = nil) where VM: StateObserver {
            getViewModel = { ReMVVMConfig.shared.viewModelProvider.viewModel(with: key) }
            if let store = store {
                wrappedValue = ViewModelProvider(with: store).viewModel(with: key)
            }
        }
    }
}
