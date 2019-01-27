//
//  ReMVVM+Rx.swift
//  ReMVVMBasicExample
//
//  Created by Dariusz Grzeszczak on 11/01/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVM
import RxSwift
import class SwiftyRedux.Store

public extension StoreActionDispatcher where Self: ObserverType {
    public func on(_ event: Event<StoreAction>) {
        guard let action = event.element else { return }
        self.dispatch(action: action)
    }
}
extension SwiftyRedux.Store: ObserverType { }
extension ReMVVM: ObserverType { }
extension Dispatcher: ObserverType { }
extension AnyDispatcher: ObserverType { }

class RxStore<State: StoreState>  {

    let state: Observable<State>

    init(with store: Store<State>) {
        state = Observable<State>.create { observer -> Disposable in
            let rxObserver = StateSubscriber(observer: observer)
            store.add(subscriber: rxObserver)

            return Disposables.create {
                store.remove(subscriber: rxObserver)
            }
        }
        .share(replay: 1)
        .startWith(store.state)
    }

    private class StateSubscriber<Element>: StoreSubscriber {
        let observer: AnyObserver<Element>
        init(observer: AnyObserver<Element>) {
            self.observer = observer
        }

        func didChange(state: Element, oldState: Element) {
            observer.onNext(state)
        }
    }
}
