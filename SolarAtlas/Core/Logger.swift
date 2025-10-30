import Foundation
import os

/// Structured logging wrapper that normalizes log formatting and metadata enrichment.
struct AppLogger {
    enum Level: String {
        case debug
        case info
        case warning
        case error

        fileprivate var osType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            }
        }
    }

    enum Category: String {
        case app
        case networking
        case firestore
        case remoteConfig
        case news
        case ads
        case consent
    }

    private static let subsystem = "com.solaratlas.app"

    static func category(_ category: Category) -> AppLogger {
        AppLogger(category: category.rawValue)
    }

    private let category: String
    private let logger: Logger?

    private init(category: String) {
        self.category = category
        if #available(iOS 14.0, *) {
            self.logger = Logger(subsystem: Self.subsystem, category: category)
        } else {
            self.logger = nil
        }
    }

    func log(_ message: String,
             level: Level = .info,
             metadata: [String: String] = [:],
             error: AppError? = nil,
             file: StaticString = #fileID,
             line: UInt = #line) {
        var mergedMetadata = metadata
        if let errorMetadata = error?.metadata {
            for (key, value) in errorMetadata {
                mergedMetadata[key] = value
            }
        }
        mergedMetadata["file"] = String(describing: file)
        mergedMetadata["line"] = String(line)

        let context = mergedMetadata
            .map { "\($0.key)=\($0.value)" }
            .sorted()
            .joined(separator: " ")

        let composedMessage = context.isEmpty ? message : "\(message) | \(context)"

        if let logger {
            logger.log(level: level.osType, "\(composedMessage, privacy: .public)")
        } else {
            print("[SolarAtlas][\(category.uppercased())][\(level.rawValue.uppercased())] \(composedMessage)")
        }
    }

    func debug(_ message: String,
               metadata: [String: String] = [:],
               error: AppError? = nil,
               file: StaticString = #fileID,
               line: UInt = #line) {
        log(message, level: .debug, metadata: metadata, error: error, file: file, line: line)
    }

    func info(_ message: String,
              metadata: [String: String] = [:],
              error: AppError? = nil,
              file: StaticString = #fileID,
              line: UInt = #line) {
        log(message, level: .info, metadata: metadata, error: error, file: file, line: line)
    }

    func warning(_ message: String,
                 metadata: [String: String] = [:],
                 error: AppError? = nil,
                 file: StaticString = #fileID,
                 line: UInt = #line) {
        log(message, level: .warning, metadata: metadata, error: error, file: file, line: line)
    }

    func error(_ message: String,
               metadata: [String: String] = [:],
               error: AppError? = nil,
               file: StaticString = #fileID,
               line: UInt = #line) {
        log(message, level: .error, metadata: metadata, error: error, file: file, line: line)
    }
}
