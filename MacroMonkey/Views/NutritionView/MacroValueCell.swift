//
//  MacroValueCell.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/19/24.
//

import SwiftUI

struct MacroValueCell: View {
    var value: Float
    var col: Color
    
    var body: some View {
        Text(String(format: value > 100 ? "%.0f" : "%.1f", value))
            .frame(width: 50, alignment: .center)
            .bold()
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundColor(col)
            .padding(4)
            .background(col.opacity(0.15))
            .cornerRadius(5)
    }
}

#Preview {
    MacroValueCell(value: 9.4, col: CALORIES_COLOR)
}
