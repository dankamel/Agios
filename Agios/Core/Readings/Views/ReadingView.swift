//
//  ReadingView.swift
//  Agios
//
//  Created by Nikola Veljanovski on 4.7.24.
//

import SwiftUI

struct ReadingView: View {
    let reading: DataReading
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(reading.subSections ?? []) { subsection in
                if let title = reading.title {
                    SubsectionView(mainReadingTitle: title, subsection: subsection)
                }
            }
        }
        .padding(16)
        .background(reading.color.gradient)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    ReadingView(reading: DataReading(id: 1, title: "Vespres", subSections: [SubSection(id: 2,
                                                                                       title: "Psalm & Gospel", introduction: nil, readings: [SubSectionReading(id: 3, title: nil, introduction: nil, conclusion: nil, passages: [Passage(bookID: 0, bookTranslation: "Psalms", chapter: nil, ref: "118:8-9", verses: [])], html: nil)])]))
}


struct SubsectionView: View {
    let mainReadingTitle: String
    let subsection: SubSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack(alignment: .leading, spacing: 6) {
                if let readings = subsection.readings {
                    ForEach(readings) { reading in
                        ForEach(reading.passages ?? []) { passage in
                            PassageView(passage: passage)
                        }
                    }
                }
            }
            .frame(height: 60, alignment: .top)
            .clipped()

            Spacer()
            HStack(spacing: 4, content: {
                Text(mainReadingTitle)
                Circle()
                    .frame(width: 4, height: 4, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                Text(subsection.title ?? "")
            })
            .font(.body)
            .fontWeight(.medium)
            .foregroundStyle(.gray900)
        }
        .frame(height: 90)
    }
}

struct PassageView: View {
    let passage: Passage
    
    var body: some View {
        Text("\(passage.bookTranslation ?? "") \(passage.ref ?? "")")
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.gray900)
    }
}
