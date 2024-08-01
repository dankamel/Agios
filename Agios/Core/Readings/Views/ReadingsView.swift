//
//  ReadingsView.swift
//  Agios
//
//  Created by Victor on 18/04/2024.
//

import SwiftUI

struct ReadingsView: View {
    
    let passage: Passage
    let verse: Verse
    let subSection: SubSection
    
    @EnvironmentObject private var occasionViewModel: OccasionsViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()
            
            Rectangle()
                .fill(LinearGradient(colors: [.primary300, .clear], startPoint: .top, endPoint: .bottom))
                .frame(height: 48)
                .frame(maxWidth: .infinity) 
                .ignoresSafeArea()
                
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .frame(width: 40, height: 5)
                    .foregroundColor(.primary400)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        //                    NavigationButton(labelName: .down)
                        //                        .onTapGesture {
                        //                            occasionViewModel.openSheet = false
                        //                        }
                        
                        VStack(alignment: .leading, spacing: 32) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("\(passage.bookTranslation ?? "")  \(passage.ref ?? "")")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                
                                HStack(alignment: .center, spacing: 8, content: {
                                    Text(subSection.title ?? "")
                                    
                                    Circle()
                                        .frame(width: 4, height: 4, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                    
                                    Text("Liturgy")
                                })
                                .font(.body)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                                .background(.primary300)
                                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                            }
                            
                            VStack(alignment: .leading, spacing: 24, content: {
                                if ((subSection.introduction?.isEmpty) != nil) {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("Introduction".uppercased())
                                            .font(.headline)
                                            .foregroundStyle(.gray400)
                                            .kerning(0.5)
                                        Text(subSection.introduction ?? "")
                                            .fontWeight(.medium)
                                            .font(.title2)
                                            .foregroundStyle(.gray900)
                                        
                                    }
                                    
                                    Divider()
                                }
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Chapter \(verse.chapter ?? 0)".uppercased())
                                        .font(.headline)
                                        .foregroundStyle(.gray400)
                                        .kerning(0.5)
                                    ForEach(passage.verses ?? []) { verse in
                                        HStack(alignment: .firstTextBaseline) {
                                            Text("\(verse.number ?? 0)")
                                                .font(.callout)
                                            Text(verse.text ?? "")
                                                .fontWeight(.medium) 
                                                .font(.title2)
                                        }
                                    }
                                }
                            })
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 48)
                    .textSelection(.enabled)
                }
                .scrollIndicators(.hidden)
            }
        }
        .kerning(-0.4)
        .foregroundStyle(.gray900)
        .fontDesign(.rounded)
    }
}

#Preview {
    ReadingsView(passage: dev.passages, verse: dev.verses, subSection: dev.subSection)
        .environmentObject(OccasionsViewModel())
}
