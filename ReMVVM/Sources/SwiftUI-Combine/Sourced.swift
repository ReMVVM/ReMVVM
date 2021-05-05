//
//  ReState.swift
//  
//
//  Created by Dariusz Grzeszczak on 21/04/2021.
//

import Foundation

#if swift(>=5.1) && canImport(Combine) && canImport(SwiftUI)
import Combine
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
class EmptyStoreUpdatable: StoreUpdatable {

    var store: Dispatcher & Source & AnyStateProvider

    init(store: Dispatcher & Source & AnyStateProvider) {
        self.store = store
    }

    func update(store:  Dispatcher & Source & AnyStateProvider) {
        guard store !== self.store else { return }
        self.store = store
        storeChanged()
    }

    func storeChanged() {

    }
}


@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@propertyWrapper
public struct Sourced<State>: DynamicProperty {

    @Environment(\.storeContainer) private var storeContainer

    public var wrappedValue: State? { wrapper.subject.value }

    private var wrapper: Wrapper

    public init() {
        wrapper = .init(store: StoreAndViewModelProvider.empty.store)
        wrapper.update(store: storeContainer.store)
    }

//    public init<S: StateSource>(source: S) where S.State == State {
//        fatalError()
//        //storeSubjectContainer.update(store: source)
//    }

    public func update() {
        wrapper.update(store: storeContainer.store)
    }

    public typealias Publisher = Publishers.CompactMap<CurrentValueSubject<State?, Never>, State>
    public var projectedValue: Publisher { wrapper.subject.compactMap { $0 } }

    class Wrapper: EmptyStoreUpdatable {

        var subject: CurrentValueSubject<State?, Never>
        var cancellable: Cancellable?
        var source: AnyStateSource<State>?

        override init(store: Dispatcher & Source & AnyStateProvider) {
            let state: State? = store.anyState()
            subject = CurrentValueSubject<State?, Never>(state)
            super.init(store: store)

            storeChanged()
        }

        override func storeChanged() {
            if store === StoreAndViewModelProvider.empty.store {
                cancellable = nil
                source = nil
            } else {
                cancellable = nil
                source = AnyStateSource<State>(source: store)
                cancellable = source?.$state.sink { [unowned subject] state in
                    subject.send(state)
                }
            }
        }
    }

//    @propertyWrapper
//    public struct Mapped<Object>: DynamicProperty {
//
//        @SwiftUI.State public var wrappedValue: Object
//
//        private var cancellable: Cancellable!
//        private var mapper: ((AnyStateSource<State>.Wrapped.Publisher) -> AnyPublisher<Object, Never>)
//
//
//        public init<Publisher>(_ closure: @escaping (AnyStateSource<State>.Wrapped.Publisher) -> Publisher) where Publisher: Combine.Publisher, Publisher.Output == Object, Publisher.Failure == Never {
//
//            mapper = { closure($0).eraseToAnyPublisher() }
//
//
//            cancellable = mapper(ReState<State>().projectedValue).map { $0 }.assign(to: \.wrappedValue, on: self)
//        }
//
//
//        mutating public func update() {
//            cancellable = mapper(ReState<State>().projectedValue).map { $0 }.assign(to: \.wrappedValue, on: self)
//        }
//
//        public var projectedValue: Binding<Object> { $wrappedValue }
//    }
}

//Rename to source ?
protocol StoreUpdatable {
    func update(store: Dispatcher & Source & AnyStateProvider)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Sourced: StoreUpdatable {
    func update(store:  Dispatcher & Source & AnyStateProvider) {
        wrapper.update(store: store)
    }
}

#endif
