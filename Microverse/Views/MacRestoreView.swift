//
//  MacRestoreView.swift
//  MacRestoreView
//
//  Created by Justin Spahr-Summers on 04/08/2021.
//

import SwiftUI
import UniformTypeIdentifiers
import Virtualization

struct MacRestoreView: View {
    @Binding var restoreImage: VZMacOSRestoreImage?
    @State var ipswPath: String = ""
    @State var loading = false
    
    var body: some View {
        let imageLoadCompleted = { (result: Result<VZMacOSRestoreImage, Error>) in
            loading = false
            guard case let .success(image) = result else {
                print("Error loading macOS restore image:", result)
                return
            }
            
            restoreImage = image
        }
        
        if let restoreImage = restoreImage {
            HStack {
                Text("Loaded image for macOS build \(restoreImage.buildVersion)")
                Button("Reset") {
                    self.restoreImage = nil
                }
            }
        } else if loading {
            ProgressView()
        } else {
            VStack {
                Button("Load Latest…") {
                    loading = true
                    VZMacOSRestoreImage.fetchLatestSupported(completionHandler: imageLoadCompleted)
                }
                PathField(title: "Path to .ipsw", path: $ipswPath, allowedContentTypes: [UTType(filenameExtension: "ipsw") ?? .data]).onChange(of: ipswPath) { newValue in
                    loading = true
                    VZMacOSRestoreImage.load(from: URL(fileURLWithPath: ipswPath), completionHandler: imageLoadCompleted)
                }
            }
        }
    }
}

struct MacRestoreView_Previews: PreviewProvider {
    struct Holder: View {
        @State var restoreImage: VZMacOSRestoreImage? = nil
        var body: some View {
            return MacRestoreView(restoreImage: $restoreImage)
        }
    }
    
    static var previews: some View {
        Holder()
    }
}
