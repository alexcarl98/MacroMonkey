//
//  ThreeCellRow.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/28/24.
//

import SwiftUI

struct ThreeCellRow: View {
    var days:Int
    var body: some View {
        HStack(spacing:0){
            ForEach(0..<3, id:\.self){ index in
                Rectangle()
                    .frame(width: 50, height: 30) // Adjust width and height as needed
                    .padding(1.3)
                    .foregroundColor(self.colorForIndex(index: index))
                    .cornerRadius(5)
            }
        }
    }
    private func colorForIndex(index: Int) -> Color {
            let remainingDays = days - index
            return remainingDays > 0 ? .red : Color.black.opacity(0.15)
        }
}

#Preview {
    ThreeCellRow(days: 3)
}
