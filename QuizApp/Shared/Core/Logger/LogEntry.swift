import Foundation

struct LogEntry: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let level: LogLevel
    let file: String
    let line: Int
    let function: String
    let message: String

    init(
        id: UUID = UUID(),
        timestamp: Date,
        level: LogLevel,
        file: String,
        line: Int,
        function: String,
        message: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.level = level
        self.file = file
        self.line = line
        self.function = function
        self.message = message
    }

    private enum CodingKeys: String, CodingKey {
        case timestamp
        case level
        case file
        case line
        case function
        case message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.level = try container.decode(LogLevel.self, forKey: .level)
        self.file = try container.decode(String.self, forKey: .file)
        self.line = try container.decode(Int.self, forKey: .line)
        self.function = try container.decode(String.self, forKey: .function)
        self.message = try container.decode(String.self, forKey: .message)
        self.id = UUID()
    }
}
