//
//  CopticDateView.swift
//  Agios
//
//  Created by Victor on 4/25/24.
//

import SwiftUI

struct CopticDateView: View {
    
    @ObservedObject private var occasionViewModel: OccasionsViewModel
    var namespace: Namespace.ID
    @State private var openCopticList: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .center, spacing: 0) {
                HStack {
                    Image(systemName: "xmark")
                        .fontWeight(.medium)
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.88)) {
                                occasionViewModel.copticDateTapped = false
                            }
                            HapticsManager.instance.impact(style: .light)
                        }
                        .opacity(openCopticList ? 1 : 0)
                        .blur(radius: openCopticList ? 0 : 6)
                    
                    Spacer()
                    
                    Text(occasionViewModel.copticDate)
                        .lineLimit(1)
                        .frame(width: 120, alignment: .leading)
                        .matchedGeometryEffect(id: "copticDate", in: namespace)
                    
                    Spacer()
                    
                    Image(systemName: "xmark")
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 12)
                
                VStack(alignment: .center, spacing: 0) {
                    Divider()
                        .background(.gray50)
                    
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(0..<10) { copticDate in
                                Button(action: {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.88)) {
                                        occasionViewModel.copticDateTapped = false
                                    }
                                    HapticsManager.instance.impact(style: .light)
                                    
                                }, label: {
                                    Text(occasionViewModel.copticDate)
                                        .padding(.vertical, 9)
                                        .padding(.horizontal, 16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(.primary100)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))
                                })
                                .buttonStyle(BouncyButton())   
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.bottom, 30)
                    }
                    .scrollIndicators(.hidden)
                    
                }
                .scaleEffect(openCopticList ? 1 : 0.3, anchor: .topTrailing)
                .blur(radius: openCopticList ? 0 : 6)
            }
            .padding(.horizontal, 16)
            .foregroundStyle(.gray900)
            .fontWeight(.medium)
            .fontDesign(.rounded)
            
            
        Rectangle()
                .fill(.linearGradient(colors: [.white, .clear], startPoint: .bottom, endPoint: .top))
                .frame(height: 40)
            
        }
        .frame(height: 310)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white)
                .matchedGeometryEffect(id: "background", in: namespace)
        )
        .mask({
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .matchedGeometryEffect(id: "mask", in: namespace)
        })
        .padding(.horizontal, 20)
        .onAppear(perform: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.88)) {
                openCopticList = true
            }
        })
    }
}

//struct CopticDateView_Preview: PreviewProvider {
//    
//    @Namespace static var namespace
//    
//    static var previews: some View {
//        CopticDateView(namespace: namespace)
//            .environmentObject(OccasionsViewModel())
//    }
//}
