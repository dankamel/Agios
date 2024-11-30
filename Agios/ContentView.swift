//
//  ContentView.swift
//  Agios
//
//  Created by Daniel Kamel on 17/04/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var occasionViewModel: OccasionsViewModel
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(OccasionsViewModel())
}
