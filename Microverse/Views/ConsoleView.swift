//
//  ConsoleView.swift
//  ConsoleView
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import SwiftUI
import SwiftTerm

struct ConsoleView: NSViewRepresentable {
    class Delegate: TerminalViewDelegate {
        var fileHandleToWriteTo: FileHandle
        
        init(fileHandleToWriteTo: FileHandle) {
            self.fileHandleToWriteTo = fileHandleToWriteTo
        }
        
        func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {}
        func setTerminalTitle(source: TerminalView, title: String) {}
        func hostCurrentDirectoryUpdate (source: TerminalView, directory: String?) {}
        func send(source: TerminalView, data: ArraySlice<UInt8>) {
            fileHandleToWriteTo.write(Data(data))
        }
        
        func scrolled(source: TerminalView, position: Double) {}
        func requestOpenLink(source: TerminalView, link: String, params: [String:String]) {}
        func bell(source: TerminalView) {}
    }
    
    var fileHandleToReadFrom: FileHandle
    let delegate: Delegate
    
    init(fileHandleToReadFrom: FileHandle, fileHandleToWriteTo: FileHandle) {
        self.fileHandleToReadFrom = fileHandleToReadFrom
        self.delegate = Delegate(fileHandleToWriteTo: fileHandleToWriteTo)
    }
    
    func makeNSView(context: Context) -> TerminalView {
        let view = TerminalView()
        view.terminalDelegate = self.delegate
        
        self.fileHandleToReadFrom.readabilityHandler = { [weak view] handle in
            let data = handle.availableData
            if let view = view {
                DispatchQueue.main.async {
                    view.feed(byteArray: [UInt8](data)[...])
                }
            }
        }
        
        return view
    }
    
    func updateNSView(_ nsView: TerminalView, context: Context) {
    }
}
