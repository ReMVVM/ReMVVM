//
//  ReMVVM+Rx.swift
//  ReMVVMBasicExample
//
//  Created by Dariusz Grzeszczak on 11/01/2019.
//  Copyright © 2019. All rights reserved.
//

#if canImport(RxSwift)
import RxSwift

//TODO move AnyStore to ReMVVM ?
//extension Store {
//    public var any: AnyStore { AnyStore(store: self) }
//}
//
//public class AnyStore: Dispatcher, Source, ReactiveCompatible {
//
//    private let store: Dispatcher & Source
//
//    public func dispatch(action: StoreAction) {
//        store.dispatch(action: action)
//    }
//
//    public func add<Observer>(observer: Observer) where Observer : StateObserver {
//        store.add(observer: observer)
//    }
//
//    public func remove<Observer>(observer: Observer) where Observer : StateObserver {
//        store.remove(observer: observer)
//    }
//
//    public init<State>(store: Store<State>) {
//        self.store = store
//    }
//}

extension ProvidedDispatcher: ReactiveCompatible { }
extension ReMVVM: ReactiveCompatible { }
extension Store: ReactiveCompatible { }
extension AnyStore: ReactiveCompatible { }
extension AnyStateSource: ReactiveCompatible { }

extension Reactive: ObserverType where Base: Dispatcher {
    public func on(_ event: Event<StoreAction>) {
        guard let action = event.element else { return }
        base.dispatch(action: action)
    }
}

extension Reactive where Base: StateSource {

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

#endif
