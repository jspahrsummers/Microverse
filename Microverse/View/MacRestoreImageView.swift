//
//  MacRestoreImageView.swift
//  MacRestoreImageView
//
//  Created by Justin Spahr-Summers on 04/08/2021.
//

import SwiftUI
import UniformTypeIdentifiers
import Virtualization

enum MacRestoreImageSource {
    case latest
    case fromFile
}

struct MacRestoreImageView: View {
    @Binding var restoreImage: VZMacOSRestoreImage?
    @State var ipswPath: String = ""
    @State var loading = false
    @State var restoreImageSource: MacRestoreImageSource = .fromFile
    
    var body: some View {
        let imageLoadCompleted = { (result: Result<VZMacOSRestoreImage, Error>) in
            loading = false
            guard case let .success(image) = result else {
                print("Error loading macOS restore image:", result)
                return
            }
            
            restoreImage = image
        }
        
        
        GroupBox("MacOS Installation") {
            HStack {
                Form {
                    Picker("System Restore Image:", selection: $restoreImageSource) {
                        Text("Latest").tag(MacRestoreImageSource.latest)
                        HStack {
                            Text("From File:")
                            PathField(title: "Path", path: $ipswPath, allowedContentTypes: [UTType(filenameExtension: "ipsw") ?? .data]).onChange(of: ipswPath) { newValue in
                                loading = true
                                VZMacOSRestoreImage.load(from: URL(fileURLWithPath: ipswPath), completionHandler: imageLoadCompleted)
                            }
                        }.tag(MacRestoreImageSource.fromFile)
                    }.pickerStyle(.inline).onChange(of: restoreImageSource) { newValue in
                        restoreImage = nil
                        
                        switch newValue {
                        case .latest:
                            loading = true
                            VZMacOSRestoreImage.fetchLatestSupported(completionHandler: imageLoadCompleted)
                            
                        case .fromFile:
                            loading = false
                        }
                    }
                    
                    if loading {
                        ProgressView()
                    } else if let restoreImage = restoreImage {
                        HStack {
                            Text("Loaded image for macOS build \(restoreImage.buildVersion)")
                            Button("Reset") {
                                self.restoreImage = nil
                            }
                        }
                    }
                }
            }
        }
    }
}

struct MacRestoreView_Previews: PreviewProvider {
    struct Holder: View {
        @State var restoreImage: VZMacOSRestoreImage? = nil
        var body: some View {
            return MacRestoreImageView(restoreImage: $restoreImage)
        }
    }
    
    static var previews: some View {
        Holder()
    }
}
