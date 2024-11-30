//
//  DatePickerView.swift
//  Agios
//
//  Created by Victor on 4/25/24.
//

import SwiftUI

struct DatePickerView: View {
    @ObservedObject private var occasionViewModel: OccasionsViewModel
    var namespace: Namespace.ID
    @State private var openDateList: Bool = false
    @State private var datePicker: Date = Date()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .center, spacing: 0) {
                HStack {
                    Image(systemName: "xmark")
                        .fontWeight(.medium)
                        .frame(width: 60, height: 30, alignment: .leading)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.88)) {
                                occasionViewModel.defaultDateTapped = false
                            }
                            HapticsManager.instance.impact(style: .light)
                        }
                        .opacity(openDateList ? 1 : 0)
                        .blur(radius: openDateList ? 0 : 6)
                 
                    Spacer()
                    
                    Text(datePicker.formatted(date: .abbreviated, time: .omitted))
                        .lineLimit(1)
                        .frame(width: 120, alignment: .leading)
                        .matchedGeometryEffect(id: "defaultDate", in: namespace)
                    
                    Spacer()
                    
                    Text("Set")
                        .fontWeight(.medium)
                        .foregroundStyle(.primary900)
                        .frame(width: 30, height: 30)
                        .padding(.horizontal)
                        .background(.primary200)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .onTapGesture {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.88)) {
                                occasionViewModel.defaultDateTapped = false
                            }
                            HapticsManager.instance.impact(style: .light)
                        }
                        .opacity(openDateList ? 1 : 0)
                        .blur(radius: openDateList ? 0 : 6)
                }
                .padding(.vertical, 12)
                
                VStack(alignment: .center, spacing: 0) {
                    Divider()
                        .background(.gray50)
                    
                    
                    DatePicker(selection: $datePicker, displayedComponents: [.date]) {
                        
                    }
                    .datePickerStyle(.graphical)
                    .environment(\.colorScheme, .light)
                    
                }
                .scaleEffect(openDateList ? 1 : 0.3, anchor: .topLeading)
                .blur(radius: openDateList ? 0 : 6)
                
            }
            .padding(.horizontal, 16)
            .foregroundStyle(.gray900)
            .fontWeight(.medium)
            .fontDesign(.rounded)
//            .onChange(of: datePicker, { oldValue, newValue in
//                withAnimation(.spring(response: 0.35, dampingFraction: 0.88)) {
//                    occasionViewModel.defaultDateTapped = false
//                    
//                }
//                HapticsManager.instance.impact(style: .light)
//            })
            
            
        Rectangle()
                .fill(.linearGradient(colors: [.white, .clear], startPoint: .bottom, endPoint: .top))
                .frame(height: 20)
            
        }
        .frame(height: 385)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white)
                .matchedGeometryEffect(id: "dateBackground", in: namespace)
        )
        .mask({
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .matchedGeometryEffect(id: "maskDate", in: namespace)
        })
        .padding(.horizontal, 20)
        .onAppear(perform: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.88)) {
                openDateList = true
            }
        })
    }
}
//
//struct DatePickerView_Preview: PreviewProvider {
//    
//    @Namespace static var namespace
//    
//    static var previews: some View {
//        DatePickerView(namespace: namespace)
//            .environmentObject(OccasionsViewModel())
//    }
//}
