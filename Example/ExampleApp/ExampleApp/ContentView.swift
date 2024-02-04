import SwiftUI
import FDAFilesManager

struct ContentView: View {

    @State private var files: [URL] = []
    @State private var errorMessage: String?
    @State private var fileContent: String = ""
    private var filesManager: FDAFilesManager

    init() {
        filesManager = FDAFilesManager(destinationDirectoryName: "com.fresneda.exampleapp")
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if let errorMessage {
                    Text("Error: \(errorMessage)")
                        .font(.subheadline)
                }
                List {
                    ForEach(files, id: \.absoluteString) { file in
                        Button(action: {
                            loadFile(path: file)
                        }, label: {
                            Text(file.lastPathComponent)
                        })
                        .swipeActions {
                            Button(action: {
                                withAnimation {
                                    deleteFile(path: file)
                                }
                            }, label: {
                                Text("Delete")
                            })
                        }
                    }
                }
                .frame(minHeight: 200,
                       maxHeight: geometry.size.height / 2)
                VStack {
                    TextField(text: $fileContent) {
                        Text("File Content")
                    }
                    Button(action: {
                        createNewFile(content: fileContent)
                    }, label: {
                        Text("Create new file")
                    })
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            checkFiles()
        }
    }

    private func checkFiles() {
        Task {
            do {
                files = try await filesManager.allFilesDirectory()
            } catch {
                setErrorMessage(error.localizedDescription)
            }
        }
    }

    private func createNewFile(content: String?) {
        Task {
            do {
                try await filesManager.createFile(name: String(UUID().uuidString.prefix(5)),
                                                  with: fileContent.data(using: .utf8))
                clearTextField()
                checkFiles()
            } catch {
                setErrorMessage(error.localizedDescription)
            }
        }
    }

    private func deleteFile(path: URL) {
        Task {
            do {
                try await filesManager.deleteFile(name: path.lastPathComponent)
                checkFiles()
            } catch {
                setErrorMessage(error.localizedDescription)
            }
        }
    }

    private func loadFile(path: URL) {
        Task { @MainActor in
            guard let file = try? Data(contentsOf: path),
                  let stringFileContent = String(data: file, encoding: .utf8) else {
                errorMessage = "File \(path.lastPathComponent) not found"
                return
            }

            fileContent = stringFileContent
        }
    }
    private func setErrorMessage(_ message: String) {
        Task { @MainActor in
            errorMessage = message
        }
    }
    private func clearTextField() {
        Task { @MainActor in
            fileContent.removeAll()
        }
    }
}

#Preview {
    ContentView()
}
