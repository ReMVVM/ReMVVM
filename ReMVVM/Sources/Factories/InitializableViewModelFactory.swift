//
//  InitializableViewModelFactory.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 18/08/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public protocol Initializable {
    init()
}

public struct InitializableViewModelFactory: ViewModelFactory {

    public init() { }

    public func creates<VM>(type: VM.Type) -> Bool {
        return type is Initializable.Type
    }

    public func create<VM>(key: String?) -> VM? {
        guard let objType = VM.self as? (Initializable.Type) else { return nil }
        return objType.init() as? VM
    }
}
