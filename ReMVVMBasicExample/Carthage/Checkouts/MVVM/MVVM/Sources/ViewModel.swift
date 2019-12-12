//
//  ViewModel.swift
//  MVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit
public typealias ViewModelContext = UIViewController
#elseif os(watchOS)
import WatchKit
public typealias ViewModelContext = WKInterfaceController
#else
import AppKit
public typealias ViewModelContext = NSViewController
#endif

public typealias ViewModel = Any

extension ViewModelContext {
    private struct AssociatedKeys {
        static var viewModelStoreKey = "com.db.viewModelStore"
    }

    var viewModelStore: ViewModelStore? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.viewModelStoreKey) as? ViewModelStore }
        set { objc_setAssociatedObject(self, &AssociatedKeys.viewModelStoreKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
}
