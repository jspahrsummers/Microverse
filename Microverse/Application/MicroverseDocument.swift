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
    static let macVM = UTType(exportedAs: "com.metacognitive.vm.macos", conformingTo: UTType.VM)
}

extension VirtualMachine {
    var contentType: UTType {
        switch self {
        #if arch(arm64)
        case .macOS:
            return .macVM
        #endif
        }
    }
}

struct MicroverseDocument: FileDocument {
    #if arch(arm64)
    static var readableContentTypes: [UTType] { [.VM, .macVM] }
    static var writableContentTypes: [UTType] { [.macVM] }
    #else
    static var readableContentTypes: [UTType] { [.VM] }
    static var writableContentTypes: [UTType] { [] }
    #endif
    
    enum PackageItem: String {
        case MetadataJSON = "metadata.json"
        case MetadataPlist = "metadata.plist"
    }

    var virtualMachine: VirtualMachine
    
    init(virtualMachine: VirtualMachine = .macOS(MacOSVirtualMachine(configuration: VirtualMachineConfiguration()))) {
        self.virtualMachine = virtualMachine
    }

    init(configuration: ReadConfiguration) throws {
        guard configuration.contentType.conforms(to: .VM) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        let wrappers = configuration.file.fileWrappers
        
        do {
            if let metadata = wrappers?[PackageItem.MetadataPlist.rawValue]?.regularFileContents {
                virtualMachine = try PropertyListDecoder().decode(VirtualMachine.self, from: metadata)
            } else if let metadata = wrappers?[PackageItem.MetadataJSON.rawValue]?.regularFileContents {
                virtualMachine = try JSONDecoder().decode(VirtualMachine.self, from: metadata)
            } else {
                throw CocoaError(.fileReadCorruptFile)
            }
        } catch {
            NSLog("Could not decode virtual machine metadata: \(error)")
            throw error
        }
        
        if !configuration.contentType.conforms(to: virtualMachine.contentType) {
            NSLog("Loaded virtual machine \(virtualMachine) had incorrect content type in document: \(configuration.contentType)")
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard virtualMachine.contentType.conforms(to: configuration.contentType) else {
            throw CocoaError(.fileWriteInvalidFileName)
        }
        
        let metadata = try PropertyListEncoder().encode(virtualMachine)
        let metadataWrapper = FileWrapper(regularFileWithContents: metadata)
        metadataWrapper.preferredFilename = PackageItem.MetadataPlist.rawValue
        
        return FileWrapper(directoryWithFileWrappers: [
            PackageItem.MetadataPlist.rawValue: metadataWrapper
        ])
    }
}
