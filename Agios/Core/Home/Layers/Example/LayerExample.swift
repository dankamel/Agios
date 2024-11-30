////
////  LayerExample.swift
////  Eyedee
////
////  Created by Raphael Salaja on 21/09/2023.
//
//import SwiftUI
//
//// MARK: - Example Layer
//
let dev = DeveloperPreview.instance
//
//struct LayerExample: View {
//    
//    let disClose: () -> Void
//    
//    @Bindable var layers: LayerModel = .init(
//        index: 0,
//        max: 4,
//        headers: [
//            0: AnyView(HomeSaintImageView(icon: dev.icon)),
//            1: AnyView(HomeSaintImageView(icon: dev.icon)),
//            2: AnyView(HomeSaintImageView(icon: dev.icon)),
//            3: AnyView(HomeSaintImageView(icon: dev.icon)),
//        ],
//        contents: [
//            0: AnyView(EmptyView()),
//            1: AnyView(HomeSaintImageView(icon: dev.icon)),
//            2: AnyView(HomeSaintImageView(icon: dev.icon)),
//            3: AnyView(HomeSaintImageView(icon: dev.icon)),
//        ],
//        buttons: [
//            0: [["Use Memoji": "memoji_placeholder"], ["Use Emoji": "laugh"], ["Use Icon": "heart"]],
//            1: [[ : ], [ : ], [ : ]],
//            2: [[ : ], [ : ], [ : ]],
//            3: [[ : ], [ : ], [ : ]],
//
//        ]
//    )
//
//    var body: some View {
//        Layer {
//            Button {
//                if layers.index == 0 {
//                    withAnimation(.spring(response: 0.38, dampingFraction: 0.88, blendDuration: 1)) {
//                        disClose()
//                        HapticsManager.instance.impact(style: .soft)
//                    }
//                    
//                } else {
//                    withAnimation(.snappy(duration: 0.18, extraBounce: 0)) {
//                        layers.toHome()
//                    }
//                }
//                
//            } label: {
//                layers.getCurrentHeader()
//                    .id("layer.stack.header.\(layers.index)")
//            }
//            //.buttonStyle(BouncyButton())
//            
//            layers.getCurrentContent()
//                .id("layer.stack.content.\(layers.index)")
//                .padding(.top, 24)
//                .onTapGesture {
//                    withAnimation(.snappy(duration: 0.18, extraBounce: 0)) {
//                        disClose()
//                    }
//                }
//
//            
//            if layers.index == 0 {
//                VStack(spacing: 16) {
//                    if !layers.getCurrentButtons()[0].isEmpty {
//                        LayerButton(text: Binding.constant(layers.getCurrentButtons()[0].keys.first ?? ""),
//                                    icon: Binding.constant(layers.getCurrentButtons()[0].values.first ?? ""),
//                                    background: .clear)
//                        {
//                            layers.toMemoji()
//                            HapticsManager.instance.impact(style: .soft)
//
//                        }
//                    }
//                    
//                    if !layers.getCurrentButtons()[1].isEmpty {
//                        LayerButton(text: Binding.constant(layers.getCurrentButtons()[1].keys.first ?? ""),
//                                    icon: Binding.constant(layers.getCurrentButtons()[1].values.first ?? ""),
//                                    background: .clear)
//                        {
//                            layers.toEmoji()
//                            HapticsManager.instance.impact(style: .soft)
//
//                        }
//                    }
//                    
//                    if !layers.getCurrentButtons()[2].isEmpty {
//                        LayerButton(text: Binding.constant(layers.getCurrentButtons()[2].keys.first ?? ""),
//                                    icon: Binding.constant(layers.getCurrentButtons()[2].values.first ?? ""),
//                                    background: .clear)
//                        {
//                            layers.toIcon()
//                            HapticsManager.instance.impact(style: .soft)
//
//                        }
//                    }
//                }
//                .padding(.vertical, layers.index > 0 ? 0 : 24)
//                .transition(.asymmetric(
//                    insertion: .scale(scale: 0.9, anchor: .top).combined(with: .opacity.animation(.smooth)).animation(.spring(response: 0.3, dampingFraction: 1, blendDuration: 1)),
//                    removal: .scale(scale: 0.8).combined(with: .opacity).animation(.spring(response: 0.02, dampingFraction: 1, blendDuration: 1))))
//
//            }
//            //.scaleEffect(layers.index == 0 ? 1 : 0.7)
//            //.opacity(layers.index == 0 ? 1 : 0)
//            
//
//        }
//    }
//}
//
//// MARK: - Preview
//
//struct LayerExamplePreview: View {
//    var body: some View {
//        ZStack {
//            
//            Color(.black.opacity(0.25))
//                .ignoresSafeArea()
//                .zIndex(1)
//
//            LayerExample{}
//                .zIndex(2)
//                //.offset(y: -70)
//        }
//    }
//}
//
//#Preview() {
//    ZStack {
//        
//        Color(.black.opacity(0.25))
//            .ignoresSafeArea()
//            .zIndex(1)
//
//        LayerExample{}
//            .zIndex(2)
//            //.offset(y: -70)
//
//    }
//}
