//
//  SingleViewModelFactory.swift
//  MVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

public struct SingleViewModelFactory<SVM: ViewModel>: ViewModelFactory {
    private let factory: () -> SVM
    public init(with factory: @escaping () -> SVM ) {
        self.factory = factory
    }

    public func create<VM: ViewModel>() -> VM? {
        guard VM.self == SVM.self else { return nil }
        return factory() as? VM
    }
}
