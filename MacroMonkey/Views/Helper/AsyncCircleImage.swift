//
//  AsyncCircleImage.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/13/24.
//

import SwiftUI

struct AsyncCircleImage: View {
    let imageName: String

    var body: some View {
        AsyncImage(url: URL(string: imageName)) { phase in
            switch phase {
                case .empty:
                    ProgressView() // Displayed while the image is loading
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 275, height: 275)
                        .clipShape(Circle())
                        .overlay { Circle().stroke(.white, lineWidth: 4) }
                        .shadow(radius: 7)
                case .failure:
                    Image(systemName: "photo") // Displayed in case of an error
                        .resizable()
                        .scaledToFit()
                        .frame(width: 275, height: 275)
                @unknown default:
                    EmptyView() // Future proofing for additional cases
            }
        }
    }
}

#Preview {
    AsyncCircleImage(imageName: "https://img.spoonacular.com/recipes/716429-556x370.jpg")
}
