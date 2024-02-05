import XCTest
@testable import FDAFilesManager

final class FDAFilesManagerTests: XCTestCase {
    var sut: FDAFilesManager!
    
    let testDirectoryName = "TestDirectory"

    override func setUpWithError() throws {
        sut = FDAFilesManager(destinationFolderName: testDirectoryName)
    }
    override func tearDown() async throws {
        for url in try await sut.allFilesDirectory() {
            try await sut.deleteFile(url: url)
        }

        sut = nil
    }

    func test_fileDirectoryIsValid() async throws {
        // Given
        let fileName: String = "ValidFile.acc"

        // When
        try await sut.createFile(name: fileName, with: "hello world".data(using: .utf8))
        let validURL = try await sut.fileDirectory(for: "ValidFile.acc")

        // Then
        let result = await sut.isFileDirectoryValid(validURL)
        XCTAssertTrue(result)
    }

    func test_getFileDirectoryWithoutFileReturnAnError() async throws {
        // Given
        let fileName: String = "InvalidFile.acc"

        // Then
        do {
            _ = try await self.sut.fileDirectory(for: fileName)
            XCTFail()
        } catch {
            XCTAssertNotNil(error as? FDAFilesManagerError)
        }
    }

    func test_getFileDirectoryWithName() async throws {
        // Given
        let fileName = "TestFile.acc"

        // When
        try await sut.createFile(name: fileName)

        // Then
        let fileURL = try await sut.fileDirectory(for: fileName)
        XCTAssertEqual(fileURL.lastPathComponent, fileName)
    }

    func test_getAllFilesDirectory() async throws {
        // Given
        let fileName = "foo"
        
        // When
        try await sut.createFile(name: fileName)
        let fileURLs = try await sut.allFilesDirectory()

        // Then
        XCTAssertFalse(fileURLs.isEmpty)
    }

    func test_createFileWithContent() async throws {
        // Given
        let fileName = "TestFile.acc"
        let fileContent = "hello world".data(using: .utf8)

        // When
        try await sut.createFile(name: fileName, with: fileContent)
        let fileURL = try await sut.fileDirectory(for: fileName)
        let content = try Data(contentsOf: fileURL)

        // Then
        XCTAssertEqual(content, fileContent)
    }

    func test_createFileWithoutContent() async throws {
        // Given
        let fileName = "TestFile.acc"

        // When
        try await sut.createFile(name: fileName)
        let fileURL = try await sut.fileDirectory(for: fileName)
        let content = try Data(contentsOf: fileURL)

        // Then
        XCTAssertTrue(content.isEmpty)
    }

    func test_deleteFile() async throws {
        // Given
        let fileName = "TestFile.acc"

        // When
        try await sut.createFile(name: fileName)
        try await sut.deleteFile(name: fileName)

        // Then
        do {
            _ = try await self.sut.fileDirectory(for: fileName)
            XCTFail()
        } catch {
            XCTAssertNotNil(error as? FDAFilesManagerError)
        }

    }

    func test_deleteFileWithUrl() async throws {
        // Given
        let fileName = "TestFile.acc"

        // When
        try await sut.createFile(name: fileName)
        let fileURL = try await sut.fileDirectory(for: fileName)
        try await sut.deleteFile(url: fileURL)

        // Then
        do {
            _ = try await self.sut.fileDirectory(for: fileName)
            XCTFail()
        } catch {
            XCTAssertNotNil(error as? FDAFilesManagerError)
        }
    }
}
