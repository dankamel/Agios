//
//  AgiosApp.swift
//  Agios
//
//  Created by Daniel Kamel on 17/04/2024.
//

import SwiftUI
import Shake

@main
struct AgiosApp: App {
    
    private var occasionViewModel = OccasionsViewModel()
    @StateObject private var iconImageViewModel = IconImageViewModel(icon: dev.icon)
    @StateObject private var imageViewModel = IconImageViewModel(icon: IconModel(id: "", created: "", updated: "", caption: "", explanation: "", story: [], image: "", croppedImage: "", iconagrapher: .iconagrapher(Iconagrapher(id: "", name: "", url: ""))))
    @StateObject private var quoteViewModel = DailyQuoteViewModel()
    @Namespace var namespace
    @Namespace var transition
    @State private var showLaunchView: Bool = true
    
    var body: some Scene {
        WindowGroup {
            ZStack(content: {
                NavigationStack {
                    HeroWrapper {
                        HomeView(occasionViewModel: occasionViewModel, namespace: namespace, transition: transition)
                            .environmentObject(imageViewModel)
                            .environmentObject(iconImageViewModel)
                            .environmentObject(quoteViewModel)
                    }
                    
                }
                
                ZStack(content: {
                    if showLaunchView {
                        LaunchView(vm: occasionViewModel, showLaunchView: $showLaunchView)
                            .transition(.opacity.animation(.easeOut(duration: 0.2)))
                    }
                })
                .zIndex(2.0)
            })
            .onAppear {
                Shake.start(apiKey: "s37m9XuXly1HV11xU5sVa9QJQ8WvrpEtU50GJ9NsLEst4e84m9yAwuZ")
            }
        }
    }
}
