//
//  UpcomingFeastView.swift
//  Agios
//
//  Created by Victor on 6/26/24.
//

import SwiftUI

struct UpcomingFeastView: View {
    @EnvironmentObject var vm: OccasionsViewModel
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            VStack(spacing: 24) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .frame(width: 40, height: 5)
                    .foregroundColor(.primary300)
                
                VStack(alignment: .center, spacing: 24) {
                    HStack(alignment: .center, spacing: 16) {
                        Rectangle()
                            .fill(.primary200)
                            .frame(height: 130, alignment: .leading)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("St. Joseph Father of Emmanuel")
                                .font(.title2)
                                .foregroundStyle(.gray900)
                                .fontWeight(.semibold)
                                .lineLimit(3)
                                .frame(width: 191, alignment: .leading)
                            
                            Text("\(vm.datePicker.formatted(date: .abbreviated, time: .omitted))")
                                .fontWeight(.medium)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 16)
                                .background(.primary100)
                                .foregroundStyle(.primary1000)
                                .clipShape(RoundedRectangle(cornerRadius: 40))
                        }
                    }
                    
                    Text("The Feast of St. Joseph, Father of Emmanuel, celebrates St. Joseph, the earthly father of Jesus Christ and the spouse of the Virgin Mary. This feast honors Joseph's vital role in the Holy Family and his exemplary life of faith, obedience, and humility.")
                        .foregroundStyle(.gray700)
                        .fontWeight(.medium)
                        .font(.title3)
                }
                
            }
            .padding(.top, 16)
            .padding(.bottom, 32)
            .padding(.horizontal, 20)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                    vm.showUpcomingView = false
                    HapticsManager.instance.impact(style: .soft)
                }
            } label: {
                NavigationButton(labelName: .close, backgroundColor: .white, foregroundColor: .gray900)
            }
            .buttonStyle(BouncyButton())
        }
        .kerning(-0.4)
        .fontDesign(.rounded)
    }
}

#Preview {
    UpcomingFeastView()
        .environmentObject(OccasionsViewModel())
}
