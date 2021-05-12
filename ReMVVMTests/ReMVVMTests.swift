//
//  ReMVVMTests.swift
//  ReMVVMTests
//
//  Created by Dariusz Grzeszczak on 19/05/2018.
//

import XCTest
import ReMVVM

struct State: StoreState {
    let factory: ViewModelFactory = CompositeViewModelFactory()

    let substate: Substate
    init(substate: Substate) {
        self.substate = substate
    }
}

struct Substate {
    let array: [Int]
    init(array: [Int]) {
        self.array = array
    }
}

//enum CalcAction: StoreAction {
//    case add(number: Int)
//}

class CalcAction: StoreAction {
    let number: Int

    init(number: Int) {
        self.number = number
    }
}

enum CalcReducer: Reducer {

    static func reduce(state: Substate, with action: CalcAction) -> Substate {
//        switch action {
//        case .add(let number):
        return Substate(array: state.array + [action.number])
//        }
    }
}

class CalcMiddleware: Middleware {
    static var numOfMiddlewares = 0
    let id: Int
    init() {
        id = Self.numOfMiddlewares
        Self.numOfMiddlewares += 1
    }

    func onNext(for state: Substate, action: CalcAction, interceptor: Interceptor<CalcAction, Substate>, dispatcher: Dispatcher) {
        //print("before next \(id)")
        interceptor.next() { _ in
            //print("after next \(id)")
        }
    }
}

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
        let array = Range(1...100000).map { $0 }
        let substate = Substate(array: array)
        let state = State(substate: substate)
        let reducer = AnyReducer<State> { state, action in
            State(substate: CalcReducer.any.reduce(state: state.substate, with: action))

        }

        //dupa(int: 0)


        let middleware = Range(1...1000).map { _ in CalcMiddleware().any }
        let stateMappers = [StateMapper<State> { $0.substate }]

        let store = Store(with: state,
                          reducer: reducer,
                          middleware: middleware,
                          stateMappers: stateMappers)

        self.measure {
            store.dispatch(action: CalcAction(number: 3))
        }

    }

    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
////        self.measure {
////            // Put the code you want to measure the time of here.
////        }
//    }
    
}
