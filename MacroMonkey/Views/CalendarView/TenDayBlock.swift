//
//  tenDayBlock.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/17/24.
//

import SwiftUI

import SwiftUI

struct TenDayBlock: View {
    var daysInARow: Int

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<2, id: \.self) { rowIndex in
                HStack(spacing: 0) {
                    ForEach(0..<5, id: \.self) { columnIndex in
                        Rectangle()
                            .frame(width: 30, height: 50)
                            .padding(1)
                            .foregroundColor(getColorForDay(dayIndex: rowIndex * 5 + columnIndex))
                    }
                }
            }
        }
    }

    private func getColorForDay(dayIndex: Int) -> Color {
        return dayIndex < daysInARow ? .red : Color.black.opacity(0.15)
    }
}

#Preview {
    TenDayBlock(daysInARow: 8)
}
