import Foundation

/// Простой синглтон-логгер, который пишет логи в текстовые файлы по дате.
final class Logger {
    static let shared = Logger()

    private let queue = DispatchQueue(label: "quizapp.logger.queue", qos: .background)
    private let fileManager = FileManager.default

    /// Конфигурация хранения логов.
    /// Можно ограничить по количеству дней и/или по количеству файлов.
    struct Retention {
        /// Сколько последних дней хранить логи. `nil` — без ограничения по дням.
        let maxDays: Int?
        /// Сколько последних файлов хранить. `nil` — без ограничения по количеству файлов.
        let maxFiles: Int?

        static let `default` = Retention(maxDays: 7, maxFiles: 50)
    }

    /// Текущая конфигурация хранения логов.
    /// Можно переопределить из приложения: `Logger.shared.retention = ...`
    var retention: Retention = .default

    private init() {}

    // MARK: - Public API

    /// Записать строку в лог.
    /// Файл лога выбирается по текущей дате (один или несколько файлов на день).
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

        // Строка для вывода в консоль (человекочитаемый формат)
        let timestamp = Self.timestampFormatter.string(from: now)
        let consoleString =
        """
        [\(timestamp)] [\(level.rawValue)] [\(fileName):\(line) \(function)]
          \(message)

        """

        // Строка для файла (одна JSON-запись на строку — удобно парсить в приложении)
        let fileString: String
        if let data = try? Self.jsonEncoder.encode(entry),
           let json = String(data: data, encoding: .utf8) {
            fileString = json + "\n"
        } else {
            // На случай ошибки кодирования — запасной текстовый формат
            fileString = consoleString
        }

        // Дублируем в консоль для удобства
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
                // Создаём пустой файл, если его ещё нет
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

            // После успешной записи — подчистим старые файлы
            try cleanupIfNeeded(in: url.deletingLastPathComponent())
        } catch {
            #if DEBUG
            print("Logger error: \(error)")
            #endif
        }
    }

    /// Удаляет старые лог-файлы согласно настройкам `retention`.
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

        // Фильтруем только наши лог-файлы
        let logFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("log_") && $0.pathExtension == "txt" }
        guard !logFiles.isEmpty else { return }

        var filesWithDates: [(url: URL, date: Date)] = []

        for url in logFiles {
            let values = try url.resourceValues(forKeys: resourceKeys)
            let date = values.creationDate ?? values.contentModificationDate ?? Date.distantPast
            filesWithDates.append((url, date))
        }

        // Сортируем по дате (от самых старых к новым)
        filesWithDates.sort { $0.date < $1.date }

        var filesToDelete = Set<URL>()

        // Ограничение по дням
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

        // Ограничение по количеству файлов
        if let maxFiles = retention.maxFiles, filesWithDates.count > maxFiles {
            let overflow = filesWithDates.count - maxFiles
            let oldestToDelete = filesWithDates.prefix(overflow).map { $0.url }
            oldestToDelete.forEach { filesToDelete.insert($0) }
        }

        // Удаляем
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
                // Если не удалось прочитать директорию, просто начнём новый файл
                todaysFiles = []
            }
        }

        // Если файлов за сегодня ещё нет — создаём первый
        if todaysFiles.isEmpty {
            let fileName = String(format: "%@_%02d.%@", baseName, 1, fileExtension)
            return logsDirectory.appendingPathComponent(fileName)
        }

        // Находим файл с максимальным индексом
        var latestFile = todaysFiles[0]
        var maxIndex = logFileIndex(from: latestFile, baseName: baseName)

        for url in todaysFiles.dropFirst() {
            let index = logFileIndex(from: url, baseName: baseName)
            if index >= maxIndex {
                maxIndex = index
                latestFile = url
            }
        }

        // Проверяем размер последнего файла
        do {
            let resourceValues = try latestFile.resourceValues(forKeys: [.fileSizeKey])
            let fileSize = Int64(resourceValues.fileSize ?? 0)

            if fileSize >= Self.maxFileSizeBytes {
                // Текущий файл переполнен — создаём следующий
                let nextIndex = max(maxIndex, 1) + 1
                let fileName = String(format: "%@_%02d.%@", baseName, nextIndex, fileExtension)
                return logsDirectory.appendingPathComponent(fileName)
            } else {
                // Продолжаем писать в существующий файл
                return latestFile
            }
        } catch {
            // В случае ошибки просто создаём новый файл
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

        // Поддержка старого формата имени "log_YYYY-MM-DD.txt"
        guard name != baseName else { return 1 }

        let prefix = baseName + "_"
        guard name.hasPrefix(prefix) else { return 1 }

        let indexString = name.dropFirst(prefix.count)
        return Int(indexString) ?? 1
    }

    // MARK: - Parsing

    /// Распарсить JSON-логи из файла в массив `LogEntry`.
    /// Ожидается формат "одна JSON-запись на строку".
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