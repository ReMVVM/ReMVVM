//
//  ReState.swift
//  
//
//  Created by Dariusz Grzeszczak on 21/04/2021.
//

import Foundation

//Rename to source ?
protocol StoreUpdatable {
    func update(store: AnyStateStore)
}

class EmptyStoreUpdatable: StoreUpdatable {

    var store: AnyStateStore

    init(store: AnyStateStore) {
        self.store = store
    }

    func update(store: AnyStateStore) {
        guard store !== self.store else { return }
        self.store = store
        storeChanged()
    }

    func storeChanged() {

    }
}


#if swift(>=5.1) && canImport(Combine) && canImport(SwiftUI)
import Combine
import SwiftUI

/**
A property wrapper that serves the State from the Store and delivers any State change via the Publisher

 ##Example

 ```
 class DetailsViewModel: ObservableObject, Initializable {

     @Published private(set) var numberFromState: Int = -1

     @Sourced private var state: SwiftUITestState?

     required init() {

         $state.map(\.number).assign(to: &$numberFromState)
     }
 }
 ```
 */
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@propertyWrapper
public struct Sourced<State>: DynamicProperty {

    @Environment(\.storeContainer) private var storeContainer

    /// current value of the State
    public var wrappedValue: State? { wrapper.subject.value }

    private var wrapper: Wrapper

    /// Creates the Sourced instance.
    public init() {
        wrapper = .init(store: StoreAndViewModelProvider.empty.store)
        wrapper.update(store: storeContainer.store)
    }

//    public init<S: StateSource>(source: S) where S.State == State {
//        fatalError()
//        //storeSubjectContainer.update(store: source)
//    }


    /// Updates the underlying value of the stored value.
    public func update() {
        wrapper.update(store: storeContainer.store)
    }

    /// publisher type
    public typealias Publisher = Publishers.CompactMap<CurrentValueSubject<State?, Never>, State>
    /// publishes every change of the State
    public var projectedValue: Publisher { wrapper.subject.compactMap { $0 } }

    class Wrapper: EmptyStoreUpdatable {

        var subject: CurrentValueSubject<State?, Never>
        var cancellable: Cancellable?
        var source: AnyStateSource<State>?

        override init(store: AnyStateStore) {
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Sourced: StoreUpdatable {
    func update(store:  AnyStateStore) {
        wrapper.update(store: store)
    }
}

#endif
