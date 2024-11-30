//
//  UpcomingFeastView.swift
//  Agios
//
//  Created by Victor on 6/26/24.
//

import SwiftUI

struct UpcomingFeastView: View {
    @ObservedObject var vm: OccasionsViewModel
    let notable: Notable
    @State private var animate: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()
            
            Rectangle()
                .fill(LinearGradient(colors: [.primary300, .clear], startPoint: .top, endPoint: .bottom))
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 0) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .frame(width: 40, height: 5)
                    .foregroundColor(.primary400)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        VStack(alignment: .leading, spacing: 16) {
                            
                            HStack(alignment: .center, spacing: 8) {
                                Image(systemName: "seal")
                                    .rotationEffect(Angle(degrees: animate ? 0 : 360))
                                    .animation(
                                        Animation.easeInOut(duration: 4)
                                            .repeatForever(autoreverses: false),
                                        value: animate
                                    )
                                    .onAppear {
                                        animate = true
                                    }
                                Text("Upcoming feast".uppercased())
                            }
                            
                                .foregroundStyle(.gray900.opacity(0.6))
                                .fontWeight(.semibold)
                                .font(.callout)
                                .kerning(1.3)
                            
                            Text(notable.title)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray900)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            if let copticDate = notable.expand?.copticDate {
                                Text("\(vm.regularDate(for: copticDate) ?? "")")
                                    .fontWeight(.medium)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 16)
                                    .font(.title3)
                                    .background(.primary100)
                                    .foregroundStyle(.primary1000)
                                    .clipShape(RoundedRectangle(cornerRadius: 40))
                            }
                        }
                        Text(notable.story)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(.gray700)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 48)
                    .padding(.bottom, 24)
                }

            }
        }
        .kerning(-0.4)
        .foregroundStyle(.gray900)
        .fontDesign(.rounded)



/*
 Button {
     withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
         vm.showUpcomingView = false
         vm.selectedNotable = nil
         HapticsManager.instance.impact(style: .soft)
     }
 } label: {
     NavigationButton(labelName: .close, backgroundColor: .white, foregroundColor: .gray900)
 }
 .buttonStyle(BouncyButton())
 */

        
        
    }
}

//#Preview {
//    UpcomingFeastView(notable: Notable(copticDate: "",
//                                       created: "",
//                                       expand: Expand(copticDate: CopticDate(created: nil,
//                                                                             day: "", id: "",
//                                                                             month: "12",
//                                                                             updated: "")),
//                                       id: "123",
//                                       story: "Story",
//                                       title: "title",
//                                       updated: "updated"))
//}
