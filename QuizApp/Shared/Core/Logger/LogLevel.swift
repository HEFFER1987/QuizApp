import Foundation

enum LogLevel: Codable, Equatable {
    case debug
    case info
    case warning
    case error
    case custom(String)

    /// String representation of the level (used in JSON and logs).
    var rawValue: String {
        switch self {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARN"
        case .error: return "ERROR"
        case .custom(let name): return name
        }
    }

    // MARK: - Codable

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        switch value {
        case "DEBUG": self = .debug
        case "INFO": self = .info
        case "WARN": self = .warning
        case "ERROR": self = .error
        default: self = .custom(value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

}
