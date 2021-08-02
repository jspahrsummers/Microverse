//
//  MicroverseDocument.swift
//  Microverse
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let VM = UTType(exportedAs: "com.metacognitive.vm", conformingTo: UTType.package)
    static let linuxVM = UTType(exportedAs: "com.metacognitive.vm.linux", conformingTo: UTType.VM)
}

struct MicroverseDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.linuxVM] }
    
    enum PackageItem: String {
        case Metadata = "metadata.json"
    }

    var virtualMachine: VirtualMachine

    init(_ vmType: VirtualMachine.Type) {
        virtualMachine = vmType.init()
    }

    init(configuration: ReadConfiguration) throws {
        guard configuration.contentType == UTType.linuxVM, let metadata = configuration.file.fileWrappers?[PackageItem.Metadata.rawValue]?.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        virtualMachine = try JSONDecoder().decode(LinuxVirtualMachine.self, from: metadata)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let metadata = try JSONEncoder().encode(virtualMachine)
        let metadataWrapper = FileWrapper(regularFileWithContents: metadata)
        metadataWrapper.preferredFilename = PackageItem.Metadata.rawValue
        
        return FileWrapper(directoryWithFileWrappers: [
            PackageItem.Metadata.rawValue: metadataWrapper
        ])
    }
}
