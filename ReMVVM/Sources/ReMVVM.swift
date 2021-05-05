//
//  ReMVVM.swift
//  ReMVVM
//
//  Created by Dariusz Grzeszczak on 30/12/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

/**
Allows to initialize ReMVVM.

Provides additional functionalities for ReMVVMDriven objects.

#Example

 - initialize ReMVVM

```
     let store = Store<State>(with: state,
                        reducer: reducer,
                        middleware: middleware,
                        stateMappers: stateMappers)

     ReMVVM.initialize(with: store)
 ```
 
 - adds functionality to ViewModelContext eg. UIViewController

```
     class LoginViewController: UIViewController, ReMVVMDriven {

         @IBOutlet private var firstNameTextField: UITextField!
         @IBOutlet private var lastNameTextField: UITextField!

         @IBAction func loginAction(_ sender: Any) {
             let action = LoginAction(firstName: firstNameTextField.text ?? "",
                                      lastName: lastNameTextField.text ?? "")

             remvvm.dispatch(action: action)
         }

         override func viewDidLoad() {
             super.viewDidLoad()

             // get view model
             guard let viewModel: LoginViewModel = remvvm.viewModel(for: self) else { return }

             // bind view model to view
         }
     }
```
 - adds functionality to StateAssociated objects eg. ViewModels

```
     struct ViewModel: StateAssociated, ReMVVMDriven {
         typealias State = ApplicationState

         // ...

         init(with source: AnyStateSource<ApplicationState> = remvvm.stateSource) {

             // ...
         }
     }
```
 */
public class ReMVVM<Base> {

    let store: Dispatcher & Source & AnyStateProvider
    let viewModelProvider: ViewModelProvider

    init() {
        store = ReMVVM<Any>.storeContainer.store
        viewModelProvider = ReMVVM<Any>.storeContainer.viewModelProvider
    }
}

extension ReMVVM where Base: StoreState {

    /// Initializes ReMVVM with the store. ReMVVM similar to Redux has only one store for the app.
    /// - Parameter store: store that will be used by ReMVVM.
    public static func initialize(with store: Store<Base>) {
        ReMVVM<Any>.initialize(with: store)
    }
}

extension ReMVVM: Dispatcher {

    /// Dispatches action in the store.
    /// - Parameter action: action to dispatch
    public func dispatch(action: StoreAction) {
        store.dispatch(action: action)
    }
}

extension ReMVVM where Base: ViewModelContext {

    /// Provides view model of specified type.
    /// - Parameters:
    ///   - context: context that viewModel's lifecycle will be assigned with. Nil means that viewModel's lifecycle will be managed by developer not by ReMVVM.
    ///   - key: optional key that identifies ViewModel type and is used by ViewModelFactory.
    public func viewModel<VM: ViewModel>(for context: ViewModelContext? = nil, for key: String? = nil) -> VM? {
        return viewModelProvider.viewModel(for: context, with: key)
    }

    /// Provides view model of specified type and register it for state changes in the store.
    /// - Parameters:
    ///   - context: context that viewModel's lifecycle will be assigned with. Nil means that viewModel's lifecycle will be managed by developer not by ReMVVM.
    ///   - key: optional key that identifies ViewModel type and is used by ViewModelFactory.
    public func viewModel<VM: ViewModel>(for context: ViewModelContext? = nil, for key: String? = nil) -> VM? where VM: StateObserver {
        return viewModelProvider.viewModel(for: context, with: key)
    }


    /// Clears all view models created for specified context.
    /// - Parameter context: context that should be cleared
    public func clear(context: ViewModelContext) {
        viewModelProvider.clear(context: context)
    }
}

extension ReMVVM where Base: StateAssociated {

    /// type of state in stateSource
    public typealias State = Base.State

    /// state source that can be used to observe state changes
    public var source: AnyStateSource<State> {
        return StoreStateSource<State>().any
    }
}

struct StoreStateSource<State>: StateSource {

    let store: Dispatcher & Source & AnyStateProvider = ReMVVM<Any>.storeContainer.store
    var state: State? { store.anyState() }

    func add<Observer>(observer: Observer) where Observer : StateObserver {
        store.add(observer: observer)
    }

    func remove<Observer>(observer: Observer) where Observer : StateObserver {
        store.remove(observer: observer)
    }
}

private class EmptyStore: Dispatcher & Source & AnyStateProvider {
    func dispatch(action: StoreAction) {}

    func add<Observer>(observer: Observer) where Observer : StateObserver { }

    func remove<Observer>(observer: Observer) where Observer : StateObserver { }

    func anyState<State>() -> State? { nil }

    static let empty = EmptyStore()
    static let emptyViewModelProvider = ViewModelProvider(with: EmptyStore.empty, factory: EmptyFactory.init)

    class EmptyFactory: ViewModelFactory {
        func creates<VM>(type: VM.Type) -> Bool { false }
        func create<VM>(key: String?) -> VM? { nil }
    }
}

class StoreAndViewModelProvider {

    let store: Dispatcher & Source & AnyStateProvider
    let viewModelProvider: ViewModelProvider

    init(store: Dispatcher & Source & AnyStateProvider, viewModelProvider: ViewModelProvider) {
        self.store = store
        self.viewModelProvider = viewModelProvider
    }

    init<State>(store: Store<State>) where State: StoreState {
        self.store = store
        viewModelProvider = ViewModelProvider(with: store)
    }

    static let empty = StoreAndViewModelProvider(store: EmptyStore.empty, viewModelProvider: EmptyStore.emptyViewModelProvider)
}

extension ReMVVM where Base == Any {


    static var _storeContainer: StoreAndViewModelProvider?
    static var storeContainer: StoreAndViewModelProvider { _storeContainer ?? .empty}

    private static var initialized: Bool = false
    static func initialize<State: StoreState>(with store: Store<State>) {
        if initialized {
            print("ReMVVM already initialized. Are you sure ?")
        } else {
            initialized = true
        }

        _storeContainer = .init(store: store)
    }
}
