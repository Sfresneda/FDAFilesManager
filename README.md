# FDAFilesManager
FileManager.default wrapper for iOS/macOS/watchOS/tvOS/iPadOS, written in Swift 5.9

## Installation
Add this SPM dependency to your project:

```
https://github.com/Sfresneda/FDAFilesManager
```

## Usage
```swift
import FDAFilesManager

let fileManager = FDAFilesManager(destinationFolderName: "com.fresneda.fdaapp")

let fileName = "file.txt"

try await fileManager.createFile(name: fileName, 
                       withContent: "Hello, World!".data(using: .utf8))
let filePath = try await fileManager.fileDirectory(for: fileName)

let fileContent = String(data: Data(contentsOf: filePath)!, 
                         encoding: .utf8)
```

## License
This project is licensed under the Apache License - see the [LICENSE](LICENSE) file for details

## Author
Sergio Fresneda - [sfresneda](https://github.com/Sfresneda)
