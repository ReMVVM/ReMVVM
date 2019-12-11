//
//  ReMVVMTests.swift
//  ReMVVMTests
//
//  Created by Dariusz Grzeszczak on 19/05/2018.
//

import XCTest
import ReMVVM

struct AppState: StoreState {
    var factory: ViewModelFactory = CompositeViewModelFactory()


}

struct Action: StoreAction {

}

class AppStoreObserver: StateObserver {

    func didChange(state: AppState, oldState: AppState?) {
        print("tested")
    }
}

struct SomeState {
    var someInt: Int

    static var dupaTest: Int! = {
        print("dupa")
        return nil
    }()
}
struct VM: StateAssociated, ReMVVMDriven, Initializable {


    typealias State = SomeState


    init() {
        self.init(with: Self.remvvm.stateSubject)
    }

    init<S: StateSubject>(with subject: S)  {

    }

    func willChange(state: SomeState) {
        print("will change: \(state)")
    }

    func didChange(state: SomeState, oldState: SomeState?) {
        print("did change: \(state) \(oldState)")
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

        let state = AppState()
        let store = Store(with: state, reducer: EmptyReducer<Action, AppState>.any)

        let observer = AppStoreObserver()
        store.add(observer: observer)
        let d = 3
    }

    func testReMVVMInit() {
        var state = SomeState(someInt: 3)

        SomeState.dupaTest = 4
        let val: Int = SomeState.dupaTest
        print(val)

        var mockSubject = MockStateSubject(state: state)
        let vm = VM(with: mockSubject)

        // test initial ??

        // update state
        state.someInt = 4
        mockSubject.updateState(state: state)

        // test updated

        //mockSubject.add(subscriber: vm)

        print("dupa")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
