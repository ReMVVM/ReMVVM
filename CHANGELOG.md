## [3.0.0](https://github.com/dgrzeszczak/ReMVVM/releases/tag/3.0.0)

#### New
- dependencies removed
- ReMVVMCore and ReMVVMSwiftUI introduced 
- Combine support added - projected publisher for state 
- Store rebuilt
- mock source 
- ReMVVMDriven removed in favor property wrappers
- @Provided changed to @ReMVVM.ViewModel
- @ReMVVM.Dispatcher, @ReMVVM.ViewModel, @ReMVVM.State, @ReMVVM.ObservedObject (ReMVVMSwiftUI) added
- willChange/didChange renamed to willReduce/didReduce


## [2.1.0](https://github.com/dgrzeszczak/ReMVVM/releases/tag/2.0.1)

#### New
- Changes required to support RxSwift 6

## [2.0.0](https://github.com/dgrzeszczak/ReMVVM/releases/tag/2.0.0)

#### New
- Documentation added
- Removed dependency to Actions framework
- Removed dependency to SwiftyRedux. It is part of ReMVVM.
-  ReMVVM initialize method moved directly to ReMVVM from ReMVVM.Config
- AnyReducer added
- @Provided propertyWrapper added
- StoreActionDispatcher renamed to Dispatcher
- StateSubbscriber renamed to StateObserver
- applyMiddleware method in Middleware refactored to onNext
- Interceptor introduced in middleware instead of middleware's Dispatcher<>/AnyDispatcher<>
- StateSubbject, AnyStateSybbject, MockStateSubbject added
- StateAssociated added
- StateMapper added

## [1.0.0](https://github.com/dgrzeszczak/ReMVVM/releases/tag/1.0.0)

#### Added
- Initial release of ReMVVM.
