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

    func onNext(for state: Substate, action: StoreAction, interceptor: Interceptor<StoreAction, Substate>, dispatcher: Dispatcher) {
        //print("before next \(id)")
        interceptor.next() { _ in
            //print("after next \(self.id)")
        }
    }
}

enum SecondAction: StoreAction {
    case first
}

class Convert: ConvertMiddleware {

    func onNext(for state: Substate, action: SecondAction, dispatcher: Dispatcher) {
        dispatcher.dispatch(action: CalcAction(number: 3))
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
        let array = Range(1...1000000).map { $0 }
        let substate = Substate(array: array)
        let state = State(substate: substate)
        let reducer = AnyReducer<State> { state, action in
            State(substate: CalcReducer.any.reduce(state: state.substate, with: action))

        }

        //dupa(int: 0)


        var middleware: [AnyMiddlewareConvertible] = Range(1...1000).map { _ in CalcMiddleware() }
        let stateMappers = [StateMapper<State> { $0.substate }]

//        let d = AnyMiddleware { CalcMiddleware()
//            [CalcMiddleware(), CalcMiddleware() ]; CalcMiddleware()
//        }


        //middleware[1000] = Convert().any
        

        let store = Store(with: state,
                          reducer: reducer,
                          middleware: middleware,
                          stateMappers: stateMappers)

        self.measure {
        store.dispatch(action: SecondAction.first)
        }

    }

    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
////        self.measure {
////            // Put the code you want to measure the time of here.
////        }
//    }
    
}
