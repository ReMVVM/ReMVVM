//
//  ReMVVMTests.swift
//  ReMVVMTests
//
//  Created by Dariusz Grzeszczak on 19/05/2018.
//

import XCTest
@testable import ReMVVM

struct TestState: FactoryStoreState {
    var factory: ViewModelFactory = CompositeViewModelFactory()

}


struct TestAAction: StoreAction { }
struct TestAMiddleware: Middleware {
    func apply(with dispatcher: Dispatcher<TestAAction>, storeState: TestState) {
        print("middleware A")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            dispatcher.dispatch(action: TestBAction())
        }
        print("middleware Aa")
    }
}
struct TestAReducer: Reducer {
    typealias Action = TestAAction

    static func reduce(state: TestState, with params: TestAAction.ParamType) -> TestState {
        print("reducer A")
        return state
    }
}

struct TestBAction: StoreAction { }
struct TestBMiddleware: Middleware {
    func apply(with dispatcher: Dispatcher<TestBAction>, storeState: TestState) {
        print("middleware B")
        dispatcher.next() { newState in
            print("middleware Baa")
        }
        print("middleware Ba")
    }
}
struct TestBReducer: Reducer {
    typealias Action = TestBAction

    static func reduce(state: TestState, with params: TestBAction.ParamType) -> TestState {
        print("reducer B")
        return state
    }
}

struct TestCMiddleware: AnyMiddleware {
    func apply<Action>(with dispatcher: Dispatcher<Action>, storeState: Any) where Action : StoreAction {
        print("middleware C")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            dispatcher.next() { newState in
                print("middleware Caa")
            }
        }
        print("middleware Ca")
    }


}
var store = Store<TestState>(with: TestState(), middleware:[TestAMiddleware(), TestCMiddleware(), TestBMiddleware()], routingEnabled: true)
var vmProvider = ViewModelProvider(with: store)

struct StructViewModel: Initializable {

}

//class ClassViewModel: StoreSubscriber, Initializable {
//    typealias State = TestState
//
//    public func didChange(state: State, oldState: State) {
//        print("tested")
//    }
//
//    required init() { }
//}
//
//public protocol AnyStoreSubscriber: class {
//    // swiftlint:disable:next identifier_name
//    func newState(state: Any)
//}
//
//public protocol StoreSubscriberr: AnyStoreSubscriber {
//    associatedtype StoreSubscriberStateType
//
//    func newState(state: StoreSubscriberStateType)
//}
//
//extension StoreSubscriberr {
//    // swiftlint:disable:next identifier_name
//    public func newState(state: Any) {
//        if let typedState = state as? StoreSubscriberStateType {
//            newState(state: typedState)
//        }
//    }
//}
//
//class PPP: StoreSubscriberr {
//    func newState(state: Any) {
//        print("AAA")
//    }
//    func newState(state: Int) {
//        print("PPP")
//    }
//}
//
//func ddd() {
//
//}
//
//public protocol Action { }
//struct BananaAction: Action { }
//public typealias DispatchFunction = (Action) -> Void
//public typealias Middleware2<State> = (@escaping DispatchFunction, @escaping () -> State?)
//    -> (@escaping DispatchFunction) -> DispatchFunction
//
//class SStore<State> {
//
//    var state: State!
//    public var dispatchFunction: DispatchFunction!
//
//    init(middleware: [Middleware2<State>]) {
//        self.dispatchFunction = middleware
//            .reversed()
//            .reduce(
//                { [unowned self] action in self._defaultDispatch(action: action) },
//                { dispatchFunction, middleware in
//                    // If the store get's deinitialized before the middleware is complete; drop
//                    // the action without dispatching.
//                    let dispatch: (Action) -> Void = { [weak self] in self?.dispatch($0) }
//                    let getState = { [weak self] in self?.state }
//                    return middleware(dispatch, getState)(dispatchFunction)
//            })
//    }
//
//    open func dispatch(_ action: Action) {
//        dispatchFunction(action)
//    }
//
//    open func _defaultDispatch(action: Action) {
//        /// call reducer
//        print("reduce")
//    }
//}
//
//let bananaMiddleware: Middleware2<Int> = { dispatch, getState -> (@escaping DispatchFunction) -> DispatchFunction in
//    print("banana main")
//    return { next -> DispatchFunction in
//        print("banana next")
//        return { action in
//            print("banana action")
//
//            next(action)
//            print("banana after next")
//        }
//    }
//}
//
//let orangeMiddleware: Middleware2<Int> = { dispatch, getState -> (@escaping DispatchFunction) -> DispatchFunction in
//    print("orange main")
//    return { next -> DispatchFunction in
//        print("orange next")
//        return { action in
//            print("orange action")
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                next(action)
//                print("orange after next")
//            }
//        }
//    }
//}

class ReMVVMTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
//        let str: StructViewModel? = vmProvider.viewModel(for: UIViewController())
//        let cls: ClassViewModel? = vmProvider.viewModel(for: UIViewController(), for: nil)
//
//        let p: PPP = PPP()
//        p.newState(state: 8)

//        let st = SStore<Int>(middleware: [bananaMiddleware, orangeMiddleware])
//        st.dispatch(BananaAction())


        store.register(reducer: TestAReducer.self)
        store.register(reducer: TestBReducer.self)

        store.dispatch(action: TestAAction())

        let expectation = XCTestExpectation(description: "Download apple.com home page")


        wait(for: [expectation], timeout: 10)
        print("hhh")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
