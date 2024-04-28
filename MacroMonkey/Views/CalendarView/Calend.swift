//
//  Calendar.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/17/24.
//

import SwiftUI

struct Calend: View {
//    var days: Int
    var streak = [0,0,0,0,0,0]
    
//    init(days: Int){
//        _days = days
//        ForEach(0...days){
//            
//        }
//        
//    }
    
    var body: some View {
        VStack(spacing:0){
            ForEach(0..<3, id:\.self){ rowIndex in
                HStack(spacing: 0) { // Adjust spacing as needed
                    if rowIndex == 1{
                        otherDayView()
                        anotherCalenderView()
                    } else {
                        ForEach(0..<2, id:\.self){ rowIndex in
                            TenDayBlock(daysInARow: 0)
                            Rectangle()
                                .frame(width: 3, height: 50) // Adjust width and height as needed
                                .foregroundColor(Color.white)
                        }
                    }
                    // around halfway, I want to make some different
                }
            }.padding(2)
        }
    }
}

#Preview {
    Calend()
}
