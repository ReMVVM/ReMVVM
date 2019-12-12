//
//  ReMVVM+Rx.swift
//  ReMVVMBasicExample
//
//  Created by Dariusz Grzeszczak on 11/01/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVM
import RxSwift

extension ReMVVM: ReactiveCompatible { }
extension Store: ReactiveCompatible { }
extension AnyStateSubject: ReactiveCompatible { }

extension Reactive: ObserverType where Base: Dispatcher {
    public func on(_ event: Event<StoreAction>) {
        guard let action = event.element else { return }
        base.dispatch(action: action)
    }
}

extension Reactive where Base: StateSubject {

    public var state: Observable<Base.State> {

        return Observable.create { [base] observer in
            let reactiveObserver = ReactiveObserver(observer)
            base.add(observer: reactiveObserver)

            return Disposables.create {
                base.remove(observer: reactiveObserver)
            }
        }
        .share(replay: 1)
    }

    private class ReactiveObserver: StateObserver {

        let observer: AnyObserver<Base.State>
        init(_ observer: AnyObserver<Base.State>) {
            self.observer = observer
        }

        func didChange(state: Base.State, oldState: Base.State?) {
            observer.onNext(state)
        }
    }
}

public protocol StateSubjectContainer: StateAssociated {
    var stateSubject: AnyStateSubject<State> { get }
}

extension ReMVVM: StateSubjectContainer, StateAssociated where Base: StateAssociated { }

extension Reactive where Base: StateSubjectContainer {

    public var state: Observable<Base.State> {
        base.stateSubject.rx.state
    }
}
