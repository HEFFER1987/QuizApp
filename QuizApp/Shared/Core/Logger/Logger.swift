import Foundation

/// A simple singleton logger that writes date-based log files.
final class Logger {
    static let shared = Logger()

    private let queue = DispatchQueue(label: "quizapp.logger.queue", qos: .background)
    private let fileManager = FileManager.default

    /// Log retention configuration.
    /// You can limit by number of days and/or number of files.
    struct Retention {
        /// How many most recent days to keep logs. `nil` means no day-based limit.
        let maxDays: Int?
        /// How many most recent files to keep. `nil` means no file-count limit.
        let maxFiles: Int?

        static let `default` = Retention(maxDays: 7, maxFiles: 50)
    }

    /// Current log retention configuration.
    /// Can be overridden from the app: `Logger.shared.retention = ...`
    var retention: Retention = .default

    private init() {}

    // MARK: - Public API

    /// Writes a log entry.
    /// The log file is chosen by current date (one or multiple files per day).
    func log(
        _ message: String,
        level: LogLevel = .info,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        let now = Date()
        let fileName = (file as NSString).lastPathComponent

        let entry = LogEntry(
            timestamp: now,
            level: level,
            file: fileName,
            line: line,
            function: function,
            message: message
        )

        // Console string (human-readable format)
        let timestamp = Self.timestampFormatter.string(from: now)
        let consoleString =
        """
        [\(timestamp)] [\(level.rawValue)] [\(fileName):\(line) \(function)]
          \(message)

        """

        // File string (one JSON record per line — convenient for parsing)
        let fileString: String
        if let data = try? Self.jsonEncoder.encode(entry),
           let json = String(data: data, encoding: .utf8) {
            fileString = json + "\n"
        } else {
            // Fallback text format if encoding fails
            fileString = consoleString
        }

        // Also print to console in DEBUG for convenience
        #if DEBUG
        print(consoleString, terminator: "")
        #endif

        queue.async { [weak self] in
            self?.appendToDailyFile(text: fileString)
        }
    }

    // MARK: - Private

    private func appendToDailyFile(text: String) {
        guard let url = dailyLogFileURL() else { return }

        do {
            if !fileManager.fileExists(atPath: url.path) {
                // Create an empty file if it doesn't exist yet
                let directory = url.deletingLastPathComponent()
                if !fileManager.fileExists(atPath: directory.path) {
                    try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
                }
                fileManager.createFile(atPath: url.path, contents: nil)
            }

            let handle = try FileHandle(forWritingTo: url)
            defer {
                try? handle.close()
            }

            try handle.seekToEnd()
            if let data = text.data(using: .utf8) {
                try handle.write(contentsOf: data)
            }

            // After a successful write, clean up old files
            try cleanupIfNeeded(in: url.deletingLastPathComponent())
        } catch {
            #if DEBUG
            print("Logger error: \(error)")
            #endif
        }
    }

    /// Deletes old log files according to `retention`.
    private func cleanupIfNeeded(in logsDirectory: URL) throws {
        let hasDaysLimit = retention.maxDays != nil
        let hasFilesLimit = retention.maxFiles != nil

        guard hasDaysLimit || hasFilesLimit else { return }
        guard fileManager.fileExists(atPath: logsDirectory.path) else { return }

        let resourceKeys: Set<URLResourceKey> = [.creationDateKey, .contentModificationDateKey]
        let allFiles = try fileManager.contentsOfDirectory(
            at: logsDirectory,
            includingPropertiesForKeys: Array(resourceKeys),
            options: [.skipsHiddenFiles]
        )

        // Filter only our log files
        let logFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("log_") && $0.pathExtension == "txt" }
        guard !logFiles.isEmpty else { return }

        var filesWithDates: [(url: URL, date: Date)] = []

        for url in logFiles {
            let values = try url.resourceValues(forKeys: resourceKeys)
            let date = values.creationDate ?? values.contentModificationDate ?? Date.distantPast
            filesWithDates.append((url, date))
        }

        // Sort by date (oldest to newest)
        filesWithDates.sort { $0.date < $1.date }

        var filesToDelete = Set<URL>()

        // Day-based limit
        if let maxDays = retention.maxDays {
            let calendar = Calendar.current
            let now = Date()
            for item in filesWithDates {
                if let diff = calendar.dateComponents([.day], from: item.date, to: now).day,
                   diff >= maxDays {
                    filesToDelete.insert(item.url)
                }
            }
        }

        // File-count limit
        if let maxFiles = retention.maxFiles, filesWithDates.count > maxFiles {
            let overflow = filesWithDates.count - maxFiles
            let oldestToDelete = filesWithDates.prefix(overflow).map { $0.url }
            oldestToDelete.forEach { filesToDelete.insert($0) }
        }

        // Delete
        for url in filesToDelete {
            try? fileManager.removeItem(at: url)
        }
    }

    private func dailyLogFileURL() -> URL? {
        guard let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let logsDirectory = documents.appendingPathComponent("Logs")
        let dateString = Self.dateFormatter.string(from: Date())
        let baseName = "log_\(dateString)"
        let fileExtension = "txt"

        var todaysFiles: [URL] = []

        if fileManager.fileExists(atPath: logsDirectory.path) {
            do {
                let allFiles = try fileManager.contentsOfDirectory(
                    at: logsDirectory,
                    includingPropertiesForKeys: [.fileSizeKey],
                    options: [.skipsHiddenFiles]
                )

                todaysFiles = allFiles.filter { url in
                    url.deletingPathExtension().lastPathComponent.hasPrefix(baseName) &&
                    url.pathExtension == fileExtension
                }
            } catch {
                // If the directory can't be read, just start a new file
                todaysFiles = []
            }
        }

        // If there are no files for today yet, create the first one
        if todaysFiles.isEmpty {
            let fileName = String(format: "%@_%02d.%@", baseName, 1, fileExtension)
            return logsDirectory.appendingPathComponent(fileName)
        }

        // Find the file with the highest index
        var latestFile = todaysFiles[0]
        var maxIndex = logFileIndex(from: latestFile, baseName: baseName)

        for url in todaysFiles.dropFirst() {
            let index = logFileIndex(from: url, baseName: baseName)
            if index >= maxIndex {
                maxIndex = index
                latestFile = url
            }
        }

        // Check the size of the latest file
        do {
            let resourceValues = try latestFile.resourceValues(forKeys: [.fileSizeKey])
            let fileSize = Int64(resourceValues.fileSize ?? 0)

            if fileSize >= Self.maxFileSizeBytes {
                // Current file is full — create the next one
                let nextIndex = max(maxIndex, 1) + 1
                let fileName = String(format: "%@_%02d.%@", baseName, nextIndex, fileExtension)
                return logsDirectory.appendingPathComponent(fileName)
            } else {
                // Keep writing to the existing file
                return latestFile
            }
        } catch {
            // On error, just create a new file
            let nextIndex = max(maxIndex, 1) + 1
            let fileName = String(format: "%@_%02d.%@", baseName, nextIndex, fileExtension)
            return logsDirectory.appendingPathComponent(fileName)
        }
    }

    // MARK: - Formatters

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private static let maxFileSizeBytes: Int64 = Int64(10 * 1024 * 1024) // ~10 MB

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()

    private func logFileIndex(from url: URL, baseName: String) -> Int {
        let name = url.deletingPathExtension().lastPathComponent

        // Support legacy name format: "log_YYYY-MM-DD.txt"
        guard name != baseName else { return 1 }

        let prefix = baseName + "_"
        guard name.hasPrefix(prefix) else { return 1 }

        let indexString = name.dropFirst(prefix.count)
        return Int(indexString) ?? 1
    }

    // MARK: - Parsing

    /// Parses JSON logs from a file into an array of `LogEntry`.
    /// Expected format: "one JSON record per line".
    static func parseLogFile(at url: URL) -> [LogEntry] {
        guard
            let data = try? Data(contentsOf: url),
            let content = String(data: data, encoding: .utf8)
        else {
            return []
        }

        let lines = content.split(whereSeparator: \.isNewline)

        return lines.compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            return try? jsonDecoder.decode(LogEntry.self, from: Data(trimmed.utf8))
        }
    }
}