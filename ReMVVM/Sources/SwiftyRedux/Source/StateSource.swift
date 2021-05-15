//
//  StateSource.swift
//  SwiftyRedux
//
//  Created by Dariusz Grzeszczak on 10/12/2019.
//  Copyright © 2019 Dariusz Grzeszczak. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "AnyStateSource")
public typealias AnyStateSubject = AnyStateSource

@available(*, deprecated, renamed: "Source")
public typealias Subject = Source

@available(*, deprecated, renamed: "StateSource")
public typealias StateSubject = StateSource

@available(*, deprecated, renamed: "MockStateSource")
public typealias MockStateSubject = MockStateSource

#if swift(>=5.1) && canImport(Combine)
import Combine

//public typealias StateSourced<State> = AnyStateSource<State>.Sourced
/// Type erased StateSource
public final class AnyStateSource<State>: StateSource {

    private let source: Source
    /// Current state value
    @Wrapped public var state: State? //{ _state() }

    /// Adds state observer
    /// - Parameter observer: observer to be notified on state changes
    public func add<Observer>(observer: Observer) where Observer : StateObserver {
        source.add(observer: observer)
    }

    /// Removes state observer
    /// - Parameter observer: observer to remove
    public func remove<Observer>(observer: Observer) where Observer : StateObserver {
        source.remove(observer: observer)
    }

    /// Initializes erased type value
    /// - Parameter source: source to erase type
    public init<S: StateSource>(source: S) where S.State == State {
        self.source = source
        _state = .init(from: source)
    }

    init(source: AnyStateStore) {
        self.source = source
        _state = .init(source: source)
    }

    @propertyWrapper
    public final class Wrapped: StateObserver {

        private let state: () -> State?

        public var wrappedValue: State? { state() }

        private var anyCurrentValueSubject: Any?
        @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
        private var currentValueSubject: CurrentValueSubject<State?, Never> {
            anyCurrentValueSubject as! CurrentValueSubject<State?, Never>
        }

        @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
        public typealias Publisher = Publishers.CompactMap<CurrentValueSubject<State?, Never>, State>

        @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
        public var projectedValue: Publisher { currentValueSubject.compactMap { $0 } }

//        init(from source: AnyStateSource<State>) {
//            if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
//                let subject = CurrentValueSubject<State?, Never>(nil)
//                anyCurrentValueSubject = subject
//                state = { subject.value }
//                source.add(observer: self)
//            } else {
//                state = { source.state }
//            }
//        }

        // TODO merge those inits
        init<S: StateSource>(from source: S) where S.State == State {
            if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
                let subject = CurrentValueSubject<State?, Never>(nil)
                anyCurrentValueSubject = subject
                state = { subject.value }
                source.add(observer: self)
            } else {
                state = { source.state }
            }
        }

        init(source: AnyStateStore) {
            if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
                let subject = CurrentValueSubject<State?, Never>(nil)
                anyCurrentValueSubject = subject
                state = { subject.value }
                source.add(observer: self)
            } else {
                state = { source.anyState() }
            }
        }

        public func didChange(state: State, oldState: State?) {
            if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
                currentValueSubject.send(state)
            }
        }
    }
}
#else
/// Type erased StateSource
public final class AnyStateSource<State>: StateSource {

    private let _state: () -> State?
    private let source: Source

    /// Current state value
    public var state: State? { _state() }

    /// Adds state observer
    /// - Parameter observer: observer to be notified on state changes
    public func add<Observer>(observer: Observer) where Observer : StateObserver {
        source.add(observer: observer)
    }

    /// Removes state observer
    /// - Parameter observer: observer to remove
    public func remove<Observer>(observer: Observer) where Observer : StateObserver {
        source.remove(observer: observer)
    }

    /// Initializes erased type value
    /// - Parameter source: source to erase type
    public init<S: StateSource>(source: S) where S.State == State {
        self.source = source
        _state = { source.state }
    }

    init(source: AnyStateStore) {
        self.source = source
        _state = .init(source: source)
    }
}
#endif

/// Source with current state
public protocol StateSource: StateAssociated, Source {
    /// Current state value
    var state: State? { get }
}

extension StateSource {
    /// type erased value
    public var any: AnyStateSource<State> {
        guard let any = self as? AnyStateSource<State> else {
            return AnyStateSource(source: self)
        }

        return any
    }
}

