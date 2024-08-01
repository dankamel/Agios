//
//  SaintImageView.swift
//  Agios
//
//  Created by Victor on 22/04/2024.
//

import SwiftUI
import Combine
import Shimmer

struct HomeSaintImageView: View {
    
    @EnvironmentObject private var viewModel: IconImageViewModel
    @EnvironmentObject private var occasionViewModel: OccasionsViewModel
    var namespace: Namespace.ID
    let icon: IconModel
    
//    @State private var selectedSaint: IconModel?
//    @State private var showDetailView: Bool = false
    
    var body: some View {
        ZStack {
            if viewModel.allowTapping {
                Rectangle()
                    .fill(.clear)
                    .background(
                        SaintImageView(icon: icon)
                            .scaledToFill()
                            .matchedGeometryEffect(id: "\(icon.id)", in: namespace)
                    )
                    .overlay(alignment: .bottom, content: {
                        Text(icon.caption ?? "")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(8)
                            .padding(.horizontal, 3)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray900.opacity(0.8))
                    })
                    .frame(width: 300, height: 350)
                    .mask({
                        RoundedRectangle(cornerRadius: 20)
                            //.matchedGeometryEffect(id: "\(icon.image)", in: namespace)
                    })                /*
                 ZStack {
                     VStack(alignment: .leading) {
                         Spacer()
                         Text(icon.caption ?? "")
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
                         SaintImageView(icon: icon)
                             .scaledToFill()
                             .mask({
                                 RoundedRectangle(cornerRadius: 16)
                                     //.matchedGeometryEffect(id: "\(icon.image)", in: namespace)
                             })
                             .matchedGeometryEffect(id: "\(icon.id)", in: namespace)
                     )
                     
                     .frame(width: 300, height: 350)
                 }
                 .mask({
                     RoundedRectangle(cornerRadius: 16)
                         //.matchedGeometryEffect(id: "\(icon.caption ?? "")", in: namespace)
                 })
 //                .background(
 //                    SaintImageView(icon: icon)
 //                        .frame(maxWidth: 300, maxHeight: 350)
 //                        .opacity(viewModel.allowTapping ? 1 : 0)
 //                        .clipped()
 //                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
 //                        .blur(radius: 10)
 //                        .offset(x:8, y: 11)
 //                        .opacity(occasionViewModel.viewState == .expanded ? 0 : 0.35)
 //                )
                 */
                
                
     
                
            } else {
                ShimmerView(heightSize: 350, cornerRadius: 24)
                    .frame(width: 300, alignment: .leading)
                    .transition(.opacity)
                    .padding(.vertical, 25)
            }
            
          
            
                
                
            
                
                
        }
        .fontDesign(.rounded)
        .fontWeight(.semibold)
        
        }
        
    }


struct HomeSaintImageView_Preview: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        HomeSaintImageView(namespace: namespace, icon: dev.icon)
            .environmentObject(IconImageViewModel(icon: dev.icon))
            .environmentObject(OccasionsViewModel())
    }
}


