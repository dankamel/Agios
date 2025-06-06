//
//  LaunchView.swift
//  Agios
//
//  Created by Victor on 5/24/24.
//

import SwiftUI


struct LaunchView: View {
    
    @State private var logoText: [String] = "Agios".map {String($0)}
    @State private var showLogoText: Bool = false
    @State private var appOpen: Bool = false
    @State private var reduceLogo: Bool = false
    @State private var reduceBackgroundOpacity: Bool = false
    @State private var moveLogoToTop: Bool = false
    @State private var reduceLogoOpacity: Bool = false
    
    private let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    @State private var counter: Int = 0
    @State private var loops: Int = 0
    @Binding var showLaunchView: Bool
    
    @ObservedObject private var vm: OccasionsViewModel
    init(vm: OccasionsViewModel, showLaunchView: Binding<Bool>) {
        self.vm = vm
        _showLaunchView = showLaunchView
    }
    
    var body: some View {
        ZStack(content: {
            Rectangle()
                .fill(.linearGradient(colors: [
                    Color(red: 0.99, green: 0.98, blue: 0.96),
                    Color(red: 0.96, green: 0.93, blue: 0.88),
                    ],
                                      startPoint: .top,
                                      endPoint: .bottom))
                .opacity(reduceBackgroundOpacity ? 0 : 1)
                .ignoresSafeArea()
                          
            Image("appIcon")
                .resizable()
                .frame(width: 149, height: 149, alignment: .center)
                .scaleEffect(appOpen ? 1 : showLogoText ? 1.3 : reduceLogo ? 0.44 : 1)
                .offset(y: moveLogoToTop ? -(UIScreen.main.bounds.height / 2.6) : 0)
                .opacity(reduceLogoOpacity ? 0 : 1)
                //.animation(.spring(response: 0.35, dampingFraction: 1, blendDuration: 1), value: showLogoText)
            
        })
        .onAppear {
            appOpen = true
            
            if appOpen {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                        showLogoText = true
                        appOpen = false
                    }
                    
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                        showLogoText = false
                        appOpen = false
                        reduceLogo = true
                    }
                    
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        reduceBackgroundOpacity = true
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                        moveLogoToTop = true
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        reduceLogoOpacity = true
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9 + 0.19) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                        vm.showCrest = true
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    showLaunchView = false
                }
                
                
            }
        }
    }
}
