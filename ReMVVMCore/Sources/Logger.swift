//
//  Logger.swift
//  
//
//  Created by Dariusz Grzeszczak on 17/03/2022.
//

import Foundation

/// Logs action dispatch
public struct Logger {

    private let tag: String
    private let option: Option
    /// Initializes the Logger
    /// - Parameters:
    ///   - tag: logger's tag
    ///   - option: logger oprtion set
    public init(tag: String, option: Option) {
        self.tag = tag
        self.option = option
    }

    public static let defaultLogger = Logger(tag: "Store", option: .default)
    public static let noLogger = Logger(tag: "Store", option: .none)
    static let defaultEmptyLogger = Logger(tag: "Empty", option: .default)
    static let defaultTestLogger = Logger(tag: "Test", option: .default)

    func logReduce<State>(state: State, oldState: State, action: StoreAction, log: Info) {
        guard option.contains(.reduce) else { return }
        var params: [String] = []
        if option.contains(.reduceState) {
            params.append("state:\t\(state)")
        }

        if option.contains(.reduceOldState) {
            params.append("oldState:\t\(oldState)")
        }

        if option.contains(.reduceAction) {
            if option.contains(.reduceActionInstance) {
                params.append("action: \(action.description)")
            } else {
                params.append("action: \(action.typeDescription)")
            }
        }
        if option.contains(.reduceInfo) {
            params.append(":\t\(log)")
        }

        self.log(.reduce, params: params)
    }

    func logMiddleware(middleware: AnyMiddleware, action: StoreAction, log: Info) {
        guard option.contains(.middleware) else { return }
        var params: [String] = []
        if option.contains(.middlewareInstance) {
            params.append("\(middleware)")
        } else {
            params.append("\(String(reflecting: type(of: middleware)))")
        }

        if option.contains(.middlewareAction) {
            if option.contains(.middlewareInstance) {
                params.append("action: \(action.description)")
            } else {
                params.append("action: \(action.typeDescription)")
            }
        }
        if option.contains(.middlewareInfo) {
            params.append(":\t\(log)")
        }

        self.log(.middleware, params: params)
    }

    func logDispatch<State>(action: StoreAction, log: Info, state: State) {
        guard option.contains(.dispatch) else { return }
        var params: [String] = []
        if option.contains(.dispatchActionInstance) {
            params.append(action.description)
        } else {
            params.append(action.typeDescription)
        }
        if option.contains(.dispatchInfo) {
            params.append(":\t\(log)")
        }
        if option.contains(.dispatchState) {
            params.append("state:\t\(state)")
        }

        self.log(.dispatch, params: params)
    }

    private enum LogType: String {
        case reduce = "Reduce"
        case middleware = "Middleware"
        case dispatch = "Dispatch"
    }

    private func log(_ logType: LogType, params: [String]) {
        log("[ReMVVM][\(logType.rawValue)][\(tag)]", params: params)
    }

    private func log(_ msg: String, params: [String]) {
        print(msg + " " + params.joined(separator: "\r\t"))
    }
}

extension Logger {

    /// Option set for Logger
    public struct Option: OptionSet {
        public typealias RawValue = UInt

        static let dispatch = Option(rawValue: 1 << 0)
        static let dispatchState = Option(rawValue: 1 << 1)
        static let dispatchInfo = Option(rawValue: 1 << 2)
        static let dispatchActionInstance = Option(rawValue: 1 << 3)

        static let middleware = Option(rawValue: 1 << 5)
        static let middlewareInfo = Option(rawValue: 1 << 6)
        static let middlewareAction = Option(rawValue: 1 << 7)
        static let middlewareActionInstance = Option(rawValue: 1 << 8)
        static let middlewareInstance = Option(rawValue: 1 << 9)

        static let reduce = Option(rawValue: 1 << 15)
        static let reduceInfo = Option(rawValue: 1 << 16)
        static let reduceAction = Option(rawValue: 1 << 17)
        static let reduceActionInstance = Option(rawValue: 1 << 18)
        static let reduceState = Option(rawValue: 1 << 19)
        static let reduceOldState = Option(rawValue: 1 << 20)

        public var rawValue: RawValue

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }

        /// Option to log dispach
        public static func dispatch(state: Bool = false, info: Bool = true, actionIstance: Bool = false) -> Option {
            var option = Option.dispatch
            if state { option.insert( .dispatchState) }
            if info { option.insert(.dispatchInfo) }
            if actionIstance { option.insert(.dispatchActionInstance) }
            return option
        }
        /// Option to log middleware
        public static func middleware(info: Bool = false, actionInstance: Bool? = nil, middlewareInstance: Bool = false) -> Option {
            var option = Option.middleware
            if info { option.insert(.middlewareInfo) }
            if let actionInstance = actionInstance {
                option.insert(.middlewareAction)
                if actionInstance {
                    option.insert(.middlewareActionInstance)
                }
            }
            if middlewareInstance { option.insert(.middlewareInstance) }
            return option
        }
        /// Option to log reduce
        public static func reduce(info: Bool = false, actionInstance: Bool? = nil, state: Bool = false, oldState: Bool = false) -> Option {
            var option = Option.reduce
            if info { option.insert(.reduceInfo) }
            if let actionInstance = actionInstance {
                option.insert(.reduceAction)
                if actionInstance {
                    option.insert(.reduceActionInstance)
                }
            }
            if state { option.insert(.reduceState) }
            if oldState { option.insert(.reduceOldState) }
            return option
        }

        public static let `default`: Option = [.dispatch(), .reduce()]
        public static let none: Option = []
    }
}

extension Logger {

    /// Information to log
    public struct Info: CustomStringConvertible {

        let msg: String
        /// Initializes the Info
        /// - Parameters:
        ///   - msg: message to log
        public init(msg: String) {
            self.msg = msg
        }

        init(file: String, function: String, line: Int) {
            msg = "\(file):\(line) \(function) "
        }

        public var description: String { msg }
    }

}

private extension StoreAction {

    var description: String { "\(self)" }
    var typeDescription: String { "\(String(reflecting: type(of: self)))" }
}
