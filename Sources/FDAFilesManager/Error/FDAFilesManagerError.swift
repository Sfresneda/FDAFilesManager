import Foundation

/// FDA Audio Player Recorder error.
public enum FDAFilesManagerError: Error, CustomStringConvertible {

    /// User documents directory can't be reached.
    case documentsDirectoryNotFound

    /// Output directory not found.
    case outputDirectoryNotFound

    /// Request file not found at documents directory.
    case fileNotFound

    case documentsDirectoryIsEmpty

    public var description: String {
        switch self {
        case .documentsDirectoryNotFound:
            return "User documents directory can't be reached"
        case .outputDirectoryNotFound:
            return "Output directory not found"
        case .fileNotFound:
            return "Request file not found at documents directory"
        case .documentsDirectoryIsEmpty:
            return "Directory is empty"
        }
    }
}
