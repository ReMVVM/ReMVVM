//
//  MVVMTests.swift
//  MVVMTests
//
//  Created by Dariusz Grzeszczak on 19/05/2018.
//  Copyright © 2018 Dariusz Grzeszczak. All rights reserved.
//

import XCTest
@testable import MVVM

class InitializableViewModel: Initializable {
    required init() { }
}

struct MyViewModel { }

struct MySecondViewModel { }

struct ParamViewModel {
    let intParam: Int
}

struct MyViewModelFactory: ViewModelFactory {
    func create<VM>() -> VM? {
        switch VM.self {
        case is MyViewModel.Type: return MyViewModel() as? VM
        case is MySecondViewModel.Type: return MySecondViewModel() as? VM
        case is ParamViewModel.Type: return ParamViewModel(intParam: 3) as? VM
        default: return nil
        }
    }
}

class MVVMTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let controller = UIViewController()
        let factory = MyViewModelFactory()
        var provider = ViewModelProviders.provider(for: controller, with: factory)
        guard let _: MyViewModel = provider.get() else { XCTFail(); return }
        guard let _: MySecondViewModel = provider.get() else { XCTFail(); return }
        guard let _: ParamViewModel = provider.get() else { XCTFail(); return }

        let singleFactory = SingleViewModelFactory { MyViewModel() }
        guard let _: MyViewModel = ViewModelProviders.provider(for: controller, with: singleFactory).get() else { XCTFail(); return }

        var compositeFactory = CompositeViewModelFactory()
        compositeFactory.add { MyViewModel() }
        compositeFactory.add { MySecondViewModel() }
        compositeFactory.add { ParamViewModel(intParam: 3) }
        provider = ViewModelProviders.provider(for: controller, with: compositeFactory)
        guard let _: MyViewModel = provider.get() else { XCTFail(); return }
        guard let _: MySecondViewModel = provider.get() else { XCTFail(); return }
        guard let _: ParamViewModel = provider.get() else { XCTFail(); return }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
