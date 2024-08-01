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
        VStack(spacing: 8) {
            ForEach(reading.subSections ?? []) { subsection in
                if let title = reading.title {
                    SubsectionView(mainReadingTitle: title, subsection: subsection)
                }
            }
        }
        .padding(16)
        .background(reading.sequentialPastel.gradient)
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
        VStack(spacing: 10) {
            if let readings = subsection.readings {
                ForEach(readings) { reading in
                    ForEach(reading.passages ?? []) { passage in
                        PassageView(passage: passage)
                    }
                }
            }
            HStack(spacing: 4, content: {
                Text(subsection.title ?? "")

                Circle()
                    .frame(width: 4, height: 4, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                
                Text(mainReadingTitle)
            })
            .font(.body)
            .fontWeight(.medium)
            .foregroundStyle(.gray900)
        }
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
