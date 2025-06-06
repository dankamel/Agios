//
//  AgiosApp.swift
//  Agios
//
//  Created by Daniel Kamel on 17/04/2024.
//

import SwiftUI
import Shake
import WidgetKit

@main
struct AgiosApp: App {
    @State private var occasionViewModel: OccasionsViewModel? = OccasionsViewModel()
    @StateObject private var versionVM = VersionCheckViewModel()
    @State private var showForceAlert = false

    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var iconImageViewModel = IconImageViewModel(icon: dev.icon)
    @StateObject private var imageViewModel = IconImageViewModel(icon: IconModel(id: "", created: "", updated: "", caption: "", explanation: "", story: [], image: "", croppedImage: "", iconagrapher: .iconagrapher(Iconagrapher(id: "", name: "", url: ""))))
    @StateObject private var quoteViewModel = DailyQuoteViewModel()
    @Namespace var namespace
    @Namespace var transition
    @State private var showLaunchView: Bool = true
    
    var body: some Scene {
        WindowGroup {
            ZStack(content: {
                if let occasionViewModel {
                    NavigationStack {
                        HeroWrapper {
                            HomeView(occasionViewModel: occasionViewModel,
                                     versionVM: versionVM,
                                     namespace: namespace, transition: transition)
                                .environmentObject(imageViewModel)
                                .environmentObject(iconImageViewModel)
                                .environmentObject(quoteViewModel)
                                .onAppear {
                                    reloadWidget()
                                }
                                .onChange(of: scenePhase) { _, newPhase in
                                    if newPhase == .active {
                                        reloadWidget()
                                    }
                                }
                        }
                    }
                    
                    ZStack(content: {
                        if showLaunchView {
                            LaunchView(vm: occasionViewModel, showLaunchView: $showLaunchView)
                                .transition(.opacity.animation(.easeOut(duration: 0.2)))
                        }
                    })
                    .zIndex(2.0)
                }
                if versionVM.updateType == .force {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .allowsHitTesting(true)
                }

                })
                    .onAppear {
                        Task {
                            await versionVM.performVersionCheck()
                            if versionVM.updateType == .force {
                                showForceAlert = true
                                occasionViewModel = nil
                            } else {
                                // ✅ Only initialize it *after* version check passes
                                occasionViewModel = occasionViewModel
                            }
                        }

                        Shake.start(apiKey: "s37m9XuXly1HV11xU5sVa9QJQ8WvrpEtU50GJ9NsLEst4e84m9yAwuZ")
                    }
                    .alert("Update Required", isPresented: $showForceAlert, actions: {
                        Button("Update") {
                            if let url = URL(string: versionVM.updateUrl) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }, message: {
                        Text(versionVM.updateMessage)
                    })
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                        if versionVM.updateType != .none {
                            checkVersion()
                        }
                    }
            }
    }
    
    private func reloadWidget() {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func checkVersion() {
        Task {
            await versionVM.performVersionCheck()

            if versionVM.updateType == .force {
                showForceAlert = true
                occasionViewModel = nil // re-block main UI just in case
            } else {
                showForceAlert = false
                if occasionViewModel == nil {
                    occasionViewModel = OccasionsViewModel()
                }
            }
        }
    }
}
