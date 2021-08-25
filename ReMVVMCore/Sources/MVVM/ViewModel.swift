//
//  ViewModel.swift
//  MVVM
//
//  Created by Dariusz Grzeszczak on 29/01/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit
typealias Context = UIViewController
#elseif os(watchOS)
import WatchKit
typealias Context = WKInterfaceController
#else
import AppKit
typealias Context = NSViewController
#endif

// todo hide Context for now - add in next version ? 
protocol ViewModelContext: AnyObject {
    var viewModelStore: ViewModelStore? { get set }
}

public typealias ViewModel = Any

extension Context: ViewModelContext {
    private struct AssociatedKeys {
        static var viewModelStoreKey = "com.db.viewModelStore"
    }

    // todo public ?
    var viewModelStore: ViewModelStore? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.viewModelStoreKey) as? ViewModelStore }
        set { objc_setAssociatedObject(self, &AssociatedKeys.viewModelStoreKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
}
