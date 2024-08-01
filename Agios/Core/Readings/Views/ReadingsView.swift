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
        ScrollView {
            VStack {
                HStack {
                    Text(subsectionTitle)
                    Spacer()
                    if let title = reading.title {
                        Text(title)
                    }
                }
                // Display the introduction of each SubSection
                if let firstSubSection = reading.subSections?.first {
                    if let introduction = firstSubSection.introduction {
                        HStack {
                            Text("INTRODUCTION")
                                .bold()
                            Spacer()
                        }
                        .padding(.top, 24)

                        Text(introduction)
                            .padding(.top, 5)
                    }
                    
                    // Display the details for each SubSectionReading
                    ForEach(firstSubSection.readings ?? []) { reading in
                        VStack(alignment: .leading, spacing: 5) {
                            // Display each passage in a separate view
                            ForEach(reading.passages ?? []) { passage in
                                PassageDetailView(passage: passage, introduction: reading.introduction, conclusion: reading.conclusion)
                                    .padding(.vertical, 5)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 24)
    }
}

struct PassageDetailView: View {
    let passage: Passage
    let introduction: String?
    let conclusion: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Display bookTranslation and ref
            if let bookTranslation = passage.bookTranslation, let ref = passage.ref {
                HStack {
                    Spacer()
                    Text("\(bookTranslation) \(ref)")
                        .bold()
                    Spacer()
                }
            }

            // Display introduction
            if let introduction = introduction {
                Text(introduction)
            }

            // Display verses
            ForEach(passage.verses ?? []) { verse in
                HStack(alignment: .top) {
                    if let number = verse.number {
                        Text("\(number)")
                    }
                    if let text = verse.text {
                        Text(text)
                    }
                }
            }

            // Display conclusion
            if let conclusion = conclusion {
                HStack {
                    Spacer()
                    Text(conclusion)
                    Spacer()
                }
            }
        }
        .padding()
    }
}

struct LiturgyReadingDetailsView: View {
    let subsection: SubSection
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Display the title of SubSection
                HStack {
                    if let subSectionTitle = subsection.title {
                        Text(subSectionTitle)
                    }
                    Spacer()
                    Text("Liturgy")
                }
                
                // Display the introduction of SubSection
                if let introduction = subsection.introduction {
                    Text(introduction)
                        .font(.subheadline)
                        .padding(.top, 5)
                }
                
                // Display the details for each SubSectionReading
                ForEach(subsection.readings ?? []) { reading in
                    VStack(alignment: .leading, spacing: 5) {
                        // Display each passage in a separate view
                        ForEach(reading.passages ?? []) { passage in
                            PassageDetailView(passage: passage, introduction: reading.introduction, conclusion: reading.conclusion)
                                .padding(.vertical, 5)
                        }
                    }
                }
            }
            .padding()
        }
    }
}
