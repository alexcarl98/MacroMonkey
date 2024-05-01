//
//  CalendarBlocks.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/28/24.
//

import SwiftUI

struct CalendarBlocks: View {
    var days: Int
    
    var body: some View {
            VStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { row in // Each row can potentially have up to 20 days (2 blocks of 10)
                    HStack(spacing: 5) {
                        ForEach(0..<2, id: \.self) { column in
                            VStack(spacing: 5) {
                                // Determine the number of days to display in each block
                                let daysInBlock = self.daysForBlock(row: row, column: column)
                                
                                if row == 1 && column == 1 {
                                    // Special case for the second column of the middle row
                                    ThreeCellRow(days: daysInBlock)
                                }
                                
                                TenDayBlock(daysInARow: daysInBlock)
                                // Optional: If you want a special row of three cells, adjust this part
                                if row == 1 && column == 0 {
                                    ThreeCellRow(days: daysInBlock)
                                }
                            }
                        }
                    }
                }
            }
        }
    func daysForBlock(row: Int, column: Int) -> Int {
        let index = row * 2 + column
        let daysPast = index * 10
        
        if daysPast >= days {
            return 0
        } else if days - daysPast >= 10 {
            return 10 // Full block of 10 days
        } else {
            return days - daysPast 
        }
    }
}

#Preview {
    CalendarBlocks(days:28)
}
