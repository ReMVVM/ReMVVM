//
//  ReMVVMTests.swift
//  ReMVVMTests
//
//  Created by Dariusz Grzeszczak on 19/05/2018.
//

import XCTest
import ReMVVMCore

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

class CalcAction: CommonTestAction {
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
            //print("after next \(self.id)")
        }
    }
}

class AnotherMiddleware: Middleware {
    static var numOfMiddlewares = 0
    let id: Int
    init() {
        id = Self.numOfMiddlewares
        Self.numOfMiddlewares += 1
    }

    func onNext(for state: Substate, action: CommonTestAction, interceptor: Interceptor<CommonTestAction, Substate>, dispatcher: Dispatcher) {
        print("before next \(id)")
        interceptor.next() { _ in
            //print("after next \(self.id)")
        }
    }
}

enum SecondAction: CommonTestAction {
    case first
}

class Convert: ConvertMiddleware {

    func onNext(for state: Substate, action: SecondAction, dispatcher: Dispatcher) {
        dispatcher.dispatch(action: CalcAction(number: 3))
    }

}

enum StateReducer: Reducer {

    static func reduce(state: State, with action: StoreAction) -> State {
        State(substate: CalcReducer.reduce(state: state.substate, with: action))
    }
}

protocol CommonTestAction: StoreAction {
    
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

        //dupa(int: 0)


        var middleware: [AnyMiddleware] = [AnotherMiddleware(), CalcMiddleware(), CalcMiddleware()]//Range(1...2).map { _ in CalcMiddleware() }
        let stateMappers = [StateMapper<State> { $0.substate }]

//        let d = AnyMiddleware { CalcMiddleware()
//            [CalcMiddleware(), CalcMiddleware() ]; CalcMiddleware()
//        }
        
        let arrayss: [any Middleware] = [CalcMiddleware(), CalcMiddleware(), AnotherMiddleware()]
        
        

        //print(type(of: middleware.first as! any Middleware).actionType)
        //print(type(of: CalcMiddleware()).actionType)
        //middleware[1000] = Convert().any
        

        let store = Store(with: state,
                          reducer: StateReducer.self,
                          middleware: middleware,
                          stateMappers: stateMappers)

        //self.measure {
        store.dispatch(action: CalcAction(number: 3))
        //}

    }

    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
////        self.measure {
////            // Put the code you want to measure the time of here.
////        }
//    }
    
}
