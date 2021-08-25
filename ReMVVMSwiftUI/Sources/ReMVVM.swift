//
//  File.swift
//  
//
//  Created by Dariusz Grzeszczak on 20/08/2021.
//

import Foundation
import ReMVVMCore

public typealias Initializable = ReMVVMCore.Initializable

//@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public enum ReMVVM {
    public static func initialize<State: StoreState>(with store: Store<State>) {
        ReMVVMCore.ReMVVM.initialize(with: store)
    }

//    public typealias State<State> = ProvidedState<State>
//    public typealias Dispatcher = ProvidedDispatcher
//    public typealias ViewModel = ProvidedViewModel
//    public typealias ObservedObject<Object> =  ProvidedObservedObject<Object> where Object: ObservableObject
}
