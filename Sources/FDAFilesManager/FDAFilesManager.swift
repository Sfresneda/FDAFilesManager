import Foundation

/// FDA Files Manager, a class to manage local files.
/// - Note: This class is thread safe.
public actor FDAFilesManager {
    private let destinationDirectoryName: String
    private let preferedDirectory: FileManager.SearchPathDirectory
    private let domainMask: FileManager.SearchPathDomainMask

    /// Initialize a new instance of FDAFilesManager.
    public init(
        destinationFolderName: String,
        on preferedDirectory: FileManager.SearchPathDirectory = .documentDirectory,
        with domainMask: FileManager.SearchPathDomainMask = .userDomainMask) {
            self.destinationDirectoryName = destinationFolderName
            self.preferedDirectory = preferedDirectory
            self.domainMask = domainMask
        }
}

// MARK: - Public methods
public extension FDAFilesManager {

    /// Check if file directory is valid.
    /// - Parameter url: File URL.
    /// - Returns: True if file directory is valid, otherwise false.
    func isFileDirectoryValid(_ url: URL) async -> Bool {
        let result = if #available(iOS 16.0, *) {
            url.path()
        } else {
            url.path
        }

        return FileManager.default.fileExists(atPath:  result)
    }

    /// Get file directory for a given name.
    /// - Parameter name: File name.
    /// - Throws: `FDAFilesManagerError.fileNotFound` if file is not found.
    /// - Returns: File directory.
    func fileDirectory(for name: String) async throws -> URL {
        let directory = await preferedDirectoryPath()?
            .appendingPathComponent(name)

        guard let directory,
              await isFileDirectoryValid(directory) else {
            throw FDAFilesManagerError.fileNotFound
        }

        return directory
    }

    /// Get all files directory.
    /// - Throws: `FDAFilesManagerError.documentsDirectoryNotFound` if documents directory is not found.
    /// - Returns: Array of file URLs.
    func allFilesDirectory() async throws -> [URL] {
        guard let directory = await preferedDirectoryPath() else {
            throw FDAFilesManagerError.documentsDirectoryNotFound
        }

        guard await isFileDirectoryValid(directory) else {
            throw FDAFilesManagerError.documentsDirectoryNotFound
        }

        let fileURLs = try FileManager
            .default
            .contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)

        return fileURLs
    }

    /// Create a file with a given name and content.
    /// - Parameters:
    ///  - name: File name.
    /// - content: File content.
    /// - Throws: `FDAFilesManagerError.documentsDirectoryNotFound` if documents directory is not found.
    func createFile(name: String, with content: Data? = nil) async throws {
        guard let directory = await preferedDirectoryPath() else {
            throw FDAFilesManagerError.documentsDirectoryNotFound
        }

        try await createDirectoryIfNeeded(directory: directory)

        let fileURL = directory.appendingPathComponent(name)

        if let content {
            try content.write(to: fileURL)
        } else {
            FileManager
                .default
                .createFile(atPath: fileURL.path,
                            contents: nil)
        }
    }

    /// Delete a file with a given name.
    /// - Parameter name: File name.
    /// - Throws: `FDAFilesManagerError.fileNotFound` if file is not found.
    func deleteFile(name: String) async throws {
        let fileURL = try await fileDirectory(for: name)
        try deleteFile(url: fileURL)
    }

    /// Delete a file with a given URL.
    /// - Parameter url: File URL.
    func deleteFile(url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
}

private extension FDAFilesManager {
    func preferedDirectoryPath() async -> URL? {
        let directory = FileManager
            .default
            .urls(for: preferedDirectory,
                  in: domainMask)

        return directory
            .first?
            .appendingPathComponent(destinationDirectoryName)
    }

    func createDirectoryIfNeeded(directory: URL) async throws {
        guard await !isFileDirectoryValid(directory) else {
            return
        }

        try FileManager.default
            .createDirectory(at: directory,
                             withIntermediateDirectories: true)
    }
}
