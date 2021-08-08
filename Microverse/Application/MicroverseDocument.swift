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
    static let macVM = UTType(exportedAs: "com.metacognitive.vm.macos", conformingTo: UTType.VM)
}

extension VirtualMachine {
    var contentType: UTType {
        switch self {
        case .linux:
            return .linuxVM
        case .macOS:
            return .macVM
        }
    }
}

struct MicroverseDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.VM, .linuxVM, .macVM] }
    static var writableContentTypes: [UTType] { [.macVM, .linuxVM] }
    
    enum PackageItem: String {
        case Metadata = "metadata.json"
    }

    var virtualMachine: VirtualMachine?
    
    init(virtualMachine: VirtualMachine? = nil) {
        self.virtualMachine = virtualMachine
    }

    init(configuration: ReadConfiguration) throws {
        guard configuration.contentType.conforms(to: .VM), let metadata = configuration.file.fileWrappers?[PackageItem.Metadata.rawValue]?.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        virtualMachine = try JSONDecoder().decode(VirtualMachine.self, from: metadata)
        if let virtualMachine = virtualMachine, !configuration.contentType.conforms(to: virtualMachine.contentType) {
            NSLog("Loaded virtual machine \(virtualMachine) had incorrect content type in document: \(configuration.contentType)")
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let virtualMachine = virtualMachine else {
            return FileWrapper(directoryWithFileWrappers: [:])
        }

        guard virtualMachine.contentType.conforms(to: configuration.contentType) else {
            throw CocoaError(.fileWriteInvalidFileName)
        }
        
        let metadata = try JSONEncoder().encode(virtualMachine)
        let metadataWrapper = FileWrapper(regularFileWithContents: metadata)
        metadataWrapper.preferredFilename = PackageItem.Metadata.rawValue
        
        return FileWrapper(directoryWithFileWrappers: [
            PackageItem.Metadata.rawValue: metadataWrapper
        ])
    }
}
