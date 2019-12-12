//
//  ReMVVMDriven.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 10/12/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

/// Marks object is driven by ReMVVM framework
public protocol ReMVVMDriven {
    associatedtype Base

    /// ReMVVM object to be used by ReMVVMDriven
    var remvvm: ReMVVM<Base> { get }
    /// ReMVVM object to be used by ReMVVMDriven
    static var remvvm: ReMVVM<Base> { get }
}

extension ReMVVMDriven {

    public var remvvm: ReMVVM<Self> { ReMVVM() }
    public static var remvvm: ReMVVM<Self> { ReMVVM() }
}
