//
//  tenDayBlock.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/17/24.
//

import SwiftUI

struct tenDayBlock: View {
    var body: some View {
        VStack(spacing:0){
            ForEach(0..<2, id:\.self){ rowIndex in
                HStack(spacing: 0) { // Adjust spacing as needed
                    ForEach(0..<5, id: \.self) { _ in
                        Rectangle()
                            .frame(width: 30, height: 50) // Adjust width and height as needed
                            .padding(1)
                            .foregroundColor(Color.black.opacity(0.15))
                    }
                }
            }
        }
    }
}

#Preview {
    tenDayBlock()
}
