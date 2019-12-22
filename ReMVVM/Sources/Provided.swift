//
//  Provided.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 10/12/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

#if swift(>=5.1)

/**
 Provides view model of specified type.

 #Example
 ```
    class GreetingsViewController: UIViewController {

     // inject view model from remvvm
     @Provided private var viewModel: GreetingsViewModel?

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
public final class Provided<VM: ViewModel> {
    private let key: String?

    /// wrapped value of view model
    public private(set) lazy var wrappedValue: VM? = {
        return ReMVVM<Any>.viewModelProvider.viewModel(with: key)
    }()

    /// Initializes property wrapper
    /// - Parameter key: optional identifier that will be used to create view model by ViewModelProvider
    public init(key: String) {
        self.key = key
    }

    /// Initializes property wrapper with no key
    public init() {
        key = nil
    }
}
#endif
