//
//  InitializableViewModelFactory.swift
//  MVVM
//
//  Created by Dariusz Grzeszczak on 02/10/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public protocol Initializable {
    init()
}

public struct InitializableViewModelFactory: ViewModelFactory {

    public init() { }

    public func create<VM>() -> VM? {
        guard let objType = VM.self as? (Initializable.Type) else { return nil }
        return objType.init() as? VM
    }
}
