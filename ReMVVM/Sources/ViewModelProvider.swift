//
//  ViewModelProvider.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import MVVM

public protocol ViewModelProvider {
    func viewModel<VM: ViewModel>(for context: ViewModelContext, for key: String?) -> VM?
}

public extension ViewModelProvider {
    func viewModel<VM: ViewModel>(for context: ViewModelContext) -> VM? {
        return viewModel(for: context, for: nil)
    }
}
