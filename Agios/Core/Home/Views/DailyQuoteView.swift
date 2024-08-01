//
//  DailyQuoteView.swift
//  Agios
//
//  Created by Victor on 5/2/24.
//

import SwiftUI

struct DailyQuoteView: View {
    @EnvironmentObject private var occasionViewModel: OccasionsViewModel
    let fact: Fact
    var body: some View {
        ZStack {
           if occasionViewModel.isLoading {
                ShimmerView(heightSize: 250, cornerRadius: 24)
                   .padding(.horizontal, 20)
           } else {
               ZStack {
                   VStack(alignment: .center, spacing: 16) {
                       Text("Daily Quote".uppercased())
                           .foregroundStyle(.gray900)
                           .fontWeight(.semibold)
                           .font(.callout)
                           .kerning(1.3)
                   
                       Text("〝 \(fact.fact ?? "Fact is empty.") 〞")
                               .multilineTextAlignment(.center)
                               .font(.title3)
                               .fontWeight(.semibold)
                               .foregroundStyle(.gray900)
                               .textSelection(.enabled)
                               .kerning(-0.4)
                       
                       Text("by fr pishoy kamel".uppercased())
                           .foregroundStyle(.gray900)
                           .fontWeight(.semibold)
                           .font(.callout)
                           .kerning(1.3)
                   }
                   .padding(.vertical, 24)
                   .padding(.horizontal, 16)
                   .background(.primary200)
                   .clipShape(RoundedRectangle(cornerRadius: 24, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))
                   .overlay(content: {
                       RoundedRectangle(cornerRadius: 24, style: .continuous)
                           .stroke(.primary900, style: StrokeStyle(lineWidth: 1, dash: [10,5], dashPhase: 3), antialiased: false)
                   })
               .padding(.horizontal, 20)
               }
               
           }
        }

    }
}

#Preview {
    DailyQuoteView(fact: dev.fact)
        .environmentObject(OccasionsViewModel())
}
