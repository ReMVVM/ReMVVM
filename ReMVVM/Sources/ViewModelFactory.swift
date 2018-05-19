//
//  ViewModelFactory.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import MVVM

public protocol ViewModelFactory {
    func creates<VM: ViewModel>(type: VM.Type) -> Bool
    func create<VM: ViewModel>(key: String?) -> VM?
}
