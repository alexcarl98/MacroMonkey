//
//  BadgesCollected.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/28/24.
//

import SwiftUI

struct BadgesCollected: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Completed Badges")
                .font(.headline)

            ScrollView(.horizontal) {
                HStack {
                    HikeBadge(name: "7-Day Streak")
                    HikeBadge(name: "1 Cycle Completed")
                        .hueRotation(Angle(degrees: 90))
                    HikeBadge(name: "Exact")
                        .grayscale(0.5)
                        .hueRotation(Angle(degrees: 45))
                }
                .padding(.bottom)
            }
        }
    }
}

#Preview {
    BadgesCollected()
}
