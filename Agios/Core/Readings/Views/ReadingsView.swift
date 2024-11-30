
//
//  ReadingsView.swift
//  Agios
//
//  Created by Victor on 18/04/2024.
//

import SwiftUI

struct ReadingsView: View {
    
    let reading: DataReading
    let subsectionTitle: String
    @EnvironmentObject private var occasionViewModel: OccasionsViewModel
    
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
                        HStack {
                            if let title = reading.title {
                                Text(title)
                            }
                            Spacer()
                            Text(subsectionTitle)
                        }
                        .foregroundStyle(.gray900)
                        .font(.title2)
                        .fontWeight(.semibold)
                        // Display the introduction of each SubSection
                        VStack(alignment: .leading, spacing: 32) {
                            
                            if let firstSubSection = reading.subSections?.first {
                                if let introduction = firstSubSection.introduction {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text("INTRODUCTION")
                                                .foregroundStyle(.gray900.opacity(0.6))
                                                .fontWeight(.semibold)
                                                .font(.callout)
                                                .kerning(1.3)
                                            Spacer()
                                        }

                                        Text(introduction)
                                            .fontWeight(.medium)
                                            .font(.title3)
                                            .foregroundStyle(.gray900)
                                    }
                                    .fontWeight(.medium)
                                    .padding(20)
                                    .background(.primary200)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                   
                                }
                                   
                                
                                //Divider()
                                
                                // Display the details for each SubSectionReading
                                ForEach(firstSubSection.readings ?? []) { reading in
                                    VStack(alignment: .leading, spacing: 16) {
                                        // Display each passage in a separate view
                                        ForEach(reading.passages ?? []) { passage in
                                            PassageDetailView(passage: passage, introduction: reading.introduction, conclusion: reading.conclusion)
                                                .padding(.bottom, 16)
                                        }
                                    }
                                }
                            }
                        }

                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }

            }
        }
        .kerning(-0.4)
        .foregroundStyle(.gray900)
        .fontDesign(.rounded)
    }
}

struct PassageDetailView: View {
    let passage: Passage
    let introduction: String?
    let conclusion: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Display bookTranslation and ref
            if let bookTranslation = passage.bookTranslation, let ref = passage.ref {
                HStack {
                    Text("\(bookTranslation) \(ref)")
                        .font(.title)
                        .fontWeight(.semibold)
                }
            }

            // Display introduction
            if let introduction = introduction {
                Text(introduction)
                    .fontWeight(.medium)
                    .font(.title3)
                    .foregroundStyle(.gray900)
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.primary200)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            // Display verses
            ForEach(passage.verses ?? []) { verse in
                HStack(alignment: .firstTextBaseline) {
                    if let number = verse.number {
                        Text("\(number)")
                            .font(.callout)
                    }
                    if let text = verse.text {
                        Text(text)
                            .fontWeight(.medium)
                            .font(.title3)
                    }
                }
            }

            // Display conclusion
            if let conclusion = conclusion {
                HStack {
                    Text(conclusion)
                        .fontWeight(.medium)
                        .font(.title3)
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.primary200)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
    }
}

struct LiturgyReadingDetailsView: View {
    let subsection: SubSection
    
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
                        // Display the title of SubSection
                        HStack {
                            Text("Liturgy")
                            Spacer()
                            if let subSectionTitle = subsection.title {
                                Text(subSectionTitle)
                            }
                        }
                        .foregroundStyle(.gray900)
                        .font(.title2)
                        .fontWeight(.semibold)
                        
                        // Display the introduction of SubSection
                        if let introduction = subsection.introduction {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("INTRODUCTION")
                                        .foregroundStyle(.gray900.opacity(0.6))
                                        .fontWeight(.semibold)
                                        .font(.callout)
                                        .kerning(1.3)
                                    Spacer()
                                }

                                Text(introduction)
                                    .fontWeight(.medium)
                                    .font(.title3)
                                    .foregroundStyle(.gray900)
                            }
                            .fontWeight(.medium)
                            .padding(20)
                            .background(.primary200)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        
                        // Display the details for each SubSectionReading
                        ForEach(subsection.readings ?? []) { reading in
                            VStack(alignment: .leading, spacing: 16) {
                                // Display each passage in a separate view
                                ForEach(reading.passages ?? []) { passage in
                                    PassageDetailView(passage: passage, introduction: reading.introduction, conclusion: reading.conclusion)
                                        .padding(.bottom, 16)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }

            }
        }
        .kerning(-0.4)
        .foregroundStyle(.gray900)
        .fontDesign(.rounded)


    }
}
