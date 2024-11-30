//
//  SynaxarsDetailsView.swift
//  Agios
//
//  Created by Victor on 18/04/2024.
//

import SwiftUI


struct SynaxarsDetailsView: View {
    //et icon: IconModel
    @Namespace var namespace
    @State var viewState: ViewState = .imageView
    @State private var showView: Bool = false
    @State private var showTest: Bool = false
    var body: some View {
        /*
         ZStack {
             switch viewState {
             case .collapsed:
                 VStack(alignment: .leading) {
                     Spacer()
                     Text("Abba Agathon")
                         .font(.body)
                         .multilineTextAlignment(.center)
                         .padding(8)
                         .padding(.horizontal, 3)
                         .foregroundColor(.white)
                         .frame(maxWidth: .infinity)
                         .background(Color.gray900.opacity(0.8))
                 }
                 .foregroundStyle(.white)
                 .background(
                     Image("placeholder")
                         .resizable()
                     //SaintImageView(icon: icon)
                         .matchedGeometryEffect(id: "back", in: namespace)
                         .scaledToFill()
                 )
                 .mask({
                     RoundedRectangle(cornerRadius: 24)
                         .matchedGeometryEffect(id: "mask", in: namespace)
                 })
                 .frame(width: 300, height: 350)
                 .onTapGesture {
                     withAnimation {
                         viewState = .expanded
                     }
                 }
                 
             case .expanded:
                 ScrollView {
                     VStack {}
                     .frame(maxWidth: .infinity)
                     .frame(height: 300)
                     .padding(20)
                     .background(
                         Image("placeholder")
                             .resizable()
                             .matchedGeometryEffect(id: "back", in: namespace)
                             .scaledToFill()
                             .onTapGesture {
                                 withAnimation {
                                     viewState = .imageView
                                 }
                             }
                     )
                     .mask({
                         RoundedRectangle(cornerRadius: 24)
                             .matchedGeometryEffect(id: "mask", in: namespace)
                     })
                     .padding(20)
                 }
                 
             case .imageView:
                 VStack {}
                 .frame(maxWidth: .infinity)
                 .frame(maxHeight: .infinity)
                 .background(
                     Image("placeholder")
                         .resizable()
                         .matchedGeometryEffect(id: "back", in: namespace)
                         .scaledToFit()
                         .zoomable()
                 )
                 .mask({
                     RoundedRectangle(cornerRadius: 0)
                         .matchedGeometryEffect(id: "mask", in: namespace)
                 })

             }
         }
         .overlay {
             Button("Go to first") {
                 withAnimation {
                     viewState = .collapsed
                 }
             }
         }
         .ignoresSafeArea()
         */
        VStack {
            SourceView(id: "View 1") {
                Rectangle()
                    .fill(.clear)
                    .background(
                        Image("placeholder")
                            .resizable()
                            .scaledToFill()
                    )
                    .overlay(alignment: .bottom, content: {
                        Text("Abba Agathon")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(8)
                            .padding(.horizontal, 3)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray900.opacity(0.8))
                            .opacity(showTest ? 0 : 1)
                    })
                    .frame(width: 300, height: 350)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .onTapGesture {
                        showView.toggle()
                        withAnimation {
                            showTest = true
                        }
                    }
            }
        }
        .padding()
        .fullScreenCover(isPresented: $showView) {
            ZStack {
                ScrollView {
                    VStack(alignment: .center, spacing: 24) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .onTapGesture {
                                showView.toggle()
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    showTest = false
                                }
                            }
                        DestinationView(id: "View 1") {
                            Rectangle()
                                .fill(.clear)
                                .background(
                                    Image("placeholder")
                                        .resizable()
                                        .scaledToFill()
                                        .matchedGeometryEffect(id: "back", in: namespace)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .frame(width: 300, height: 400)
                                .onTapGesture {
                                    withAnimation {
                                        viewState = .expanded
                                    }
                                    
                                }
                            
                                
                        }
                        Text("Difficulty on insensible reasonable in. From as went he they. Preference themselves me as thoroughly partiality considered on in estimating. Middletons acceptance discovered projecting so is so or. In or attachment inquietude remarkably comparison at an. Is surrounded prosperous stimulated am me discretion expression. But truth being state can she china widow. Occasional preference fat remarkably now projecting uncommonly dissimilar. Sentiments projection particular companions interested do at my delightful. Listening newspaper in advantage frankness to concluded unwilling. \n Difficulty on insensible reasonable in. From as went he they. Preference themselves me as thoroughly partiality considered on in estimating. Middletons acceptance discovered projecting so is so or. In or attachment inquietude remarkably comparison at an. Is surrounded prosperous stimulated am me discretion expression.")
                            .font(.title2)
                    }
                    .padding(24)
                }
                
                if viewState == .expanded {
                    Rectangle()
                        .fill(.clear)
                        .background(
                            Image("placeholder")
                                .resizable()
                                .scaledToFit()
                                .matchedGeometryEffect(id: "back", in: namespace)
                        )
                        .zoomable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onTapGesture {
                            withAnimation {
                                viewState = .imageView
                            }
                            
                        }
                        .transition(.scale(scale: 1))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .interactiveDismissDisabled()
        }
        .heroLayer(id: "View 1", animate: $showView) {
            Rectangle()
                .fill(.clear)
                .background(
                    Image("placeholder")
                        .resizable()
                        .scaledToFill()
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))
        } completion: { status in
            print(status ? "Open" : "Close")
        }
    }
}

#Preview {
    HeroWrapper {
        SynaxarsDetailsView()
    }
    
}




/*
 ZStack {
     if !show {
         VStack(alignment: .leading) {
             Spacer()
             Text("Abba Agathon")
                 .font(.body)
                 //.matchedGeometryEffect(id: "title", in: namespace)
                 .multilineTextAlignment(.center)
                 .padding(8)
                 .padding(.horizontal, 3)
                 .foregroundColor(.white)
                 .frame(maxWidth: .infinity)
                 .background(Color.gray900.opacity(0.8))
         }
         //.padding(20)
         .foregroundStyle(.white)
         .background(
             Image("Abba Agathon")
                 .resizable()
                 .matchedGeometryEffect(id: "back", in: namespace)
                 .scaledToFill()
                 
         )
         .mask({
             RoundedRectangle(cornerRadius: 24)
                 .matchedGeometryEffect(id: "mask", in: namespace)
         })
         .frame(width: 300, height: 350)
         
             
     } else {
         ScrollView {
             VStack(alignment: .trailing) {
                 Spacer()
                 Text("Example of match geo")
                     .matchedGeometryEffect(id: "sub", in: namespace)
                 Text("Zuriks")
                     .matchedGeometryEffect(id: "title", in: namespace)
                     .frame(maxWidth: .infinity, alignment: .trailing)
                     .font(.title)
                 
             }
             .onTapGesture {
                 withAnimation {
                     show.toggle()
                 }
             }
             .frame(height: 300)
             .padding(20)
             .foregroundStyle(.yellow)
             .background(
                 Image("Abba Agathon")
                     .resizable()
                     .matchedGeometryEffect(id: "back", in: namespace)
                     .scaledToFill()
                 
             )
             .mask({
                 RoundedRectangle(cornerRadius: 24)
                     .matchedGeometryEffect(id: "mask", in: namespace)
             })
         }
             
     }
 }
 .onTapGesture {
     withAnimation {
         show.toggle()
     }
 }

 */
