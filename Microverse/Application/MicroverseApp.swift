//
//  MicroverseApp.swift
//  Microverse
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import SwiftUI

@main
struct MicroverseApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: MicroverseDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
