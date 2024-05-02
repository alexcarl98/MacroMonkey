//
//  JOURNEY.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 5/2/24.
//

import SwiftUI

struct JOURNEY: View {
    @EnvironmentObject var macroDB: MacroDB

        var body: some View {
            VStack {
                Button("Pretend Write Today's Intake") {
                    macroDB.pretendWriteTodaysIntake()
                }
                Button("Pretend Read Today's Intake") {
                    Task {
                        do {
                            let dailyIntake = try await macroDB.pretendReadTodaysIntake(userId: "DhhiEGYR47Ft2l1xO4hO", date: "5-1-2024")
                            print("User ID: \(dailyIntake.userId)")
                            print("Date: \(dailyIntake.date)")
                            for entry in dailyIntake.entries {
                                print("Food ID: \(entry.foodId), Serving Size: \(entry.servingSize), Meal Type: \(entry.mealType), Timestamp: \(entry.timestamp)")
                            }
                        } catch {
                            print("Error reading daily intake: \(error)")
                        }
                    }
                }
            }
        }
}

#Preview {
    JOURNEY()
        .environmentObject(MacroDB())
}
