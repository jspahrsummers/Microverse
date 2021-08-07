//
//  DiskCreationView.swift
//  DiskCreationView
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import SwiftUI

struct DiskCreationView: View {
    @State private var diskSizeGB: Float = 4
    
    var body: some View {
        let numberFormatter = NumberFormatter()
        
        HStack {
            Form {
                TextField("Disk Size (GB):", value: $diskSizeGB, formatter: numberFormatter)
            }
        }
    }
}

struct DiskCreationView_Previews: PreviewProvider {
    static var previews: some View {
        DiskCreationView()
    }
}
