//
//  NSWindowExtensions.swift
//  NSWindowExtensions
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import Foundation
import SwiftUI

extension NSWindow {
    convenience init<Content: View>(rootView: Content) {
        let viewController = NSHostingController(rootView: rootView)
        self.init(contentViewController: viewController)
    }
}
