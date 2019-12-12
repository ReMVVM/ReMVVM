//
//  Provided.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 10/12/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

#if swift(>=5.1)
/// Provides view model of specified type.
@propertyWrapper
public final class Provided<VM: ViewModel> {
    private let key: String?
    public private(set) lazy var wrappedValue: VM? = {
        return ReMVVM<Any>.viewModelProvider.viewModel(with: key)
    }()

    public init(key: String) {
        self.key = key
    }

    public init() {
        key = nil
    }
}
#endif
