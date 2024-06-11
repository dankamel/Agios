//
//  OccasionsViewModel.swift
//  Agios
//
//  Created by Victor on 19/04/2024.
//

import Foundation
import Combine
import SwiftUI


struct DateModel: Identifiable {
    let id: String = UUID().uuidString
    let month: String
    let day: String
    var urlLink: String
}



class OccasionsViewModel: ObservableObject {
    @Published var icons: [IconModel] = []
    @Published var selectedCopticDate: DateModel? = nil
    @Published var filteredIcons: [IconModel] = []
    @Published var stories: [Story] = []
    @Published var readings: [DataReading] = []
    @Published var selectedItem: Bool = false
    @Published var dataClass: DataClass? = nil
    @Published var subSection: [SubSection] = []
    @Published var subSectionReading: [SubSectionReading] = []
    @Published var passages: [Passage] = []
    @Published var iconagrapher: Iconagrapher? = nil
    @Published var highlight: [Highlight] = []
    @Published var newCopticDate: CopticDate? = nil {
            didSet {
                updateMockDates()
            }
        }
    @Published var fact: [Fact]? = nil
    @Published var matchedStory: Story? = nil
    
    @Published var isShowingFeastName = true
    @Published var isLoading: Bool = false
    @Published var copticDateTapped: Bool = false
    @Published var defaultDateTapped: Bool = false
    @Published var openSheet: Bool = false
    @Published var selectedDate: Date = Date()
    @Published var showImageViewer: Bool = false
    @Published var selectedSaint: IconModel? = nil
    @Published var imageViewerOffset: CGSize = .zero
    @Published var backgroundOpacity: Double = 1
    @Published var imageScaling: Double = 1
    @Published var searchDate: String = ""
    @Published var showLaunchView: Bool = false
    @Published var showStory: Bool = false
    
    @Published var mockDates: [DateModel] = []
    

    var feastName: String?
    var liturgicalInformation: String?
    var occasionName: String {
        dataClass?.name ?? "Unknown Occasion"
    }
    
    
    private var task: URLSessionDataTask?
    
    init() {
        getPosts()
        withAnimation {
            self.isLoading = true
        }
        updateMockDates()
    }
    
    private func updateMockDates() {
        mockDates = [
            DateModel(month: "\(newCopticDate?.month ?? "")", day: "\(newCopticDate?.day ?? "")", urlLink: "gr3wna6vjuucyj8"),
            DateModel(month: "\(newCopticDate?.month ?? "")", day: "\(newCopticDate?.day ?? "")", urlLink: "a5k50zty9scwmll")
        ]
    }
    
    
    func filterIconsByCaption(icons: [IconModel], captionKeyword: String) -> [IconModel] {
        return icons.filter { $0.caption?.contains(captionKeyword) == true }
    }
    
    
    func getStory(forIcon icon: IconModel) -> Story? {
        guard let storyID = icon.story?.first else { return nil }
        return stories.first { $0.id == storyID }
    }
    
    func getPosts() {
        guard let url = URL(string: "https://api.agios.co/occasions/get/\(selectedCopticDate?.urlLink ?? "a5k50zty9scwmll")") else { return }
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                let decodedResponse = try handleOutput(response: response, data: data)
                await MainActor.run {
                    self.updateUI(with: decodedResponse)
                }
            } catch {
                print("Error fetching data: \(error)")
            }
        }
    }
    
    func handleOutput(response: URLResponse, data: Data) throws -> Response {
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }
    
    func updateUI(with response: Response) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9, blendDuration: 1)) {
            self.isLoading = false
        }
        
        self.icons = response.data.icons ?? []
        self.stories = response.data.stories ?? []
        self.readings = response.data.readings ?? []
        self.dataClass = response.data
        self.newCopticDate = response.data.copticDate ?? nil
        self.fact = response.data.facts ?? []
        self.retrievePassages()
        
        
        for icon in response.data.icons ?? [] {
            if case let .iconagrapher(iconagrapher) = icon.iconagrapher {
                self.iconagrapher = iconagrapher
            }
            
            for story in response.data.stories ?? [] {
                if icon.story?.first == story.id ?? "" {
                    self.matchedStory = story
                }
            }
            
           
        }
        
        for reading in response.data.readings ?? [] {
            self.subSection = reading.subSections ?? []
        }
        
        for story in self.stories {
            self.highlight = story.highlights ?? []
        }
        
                
        self.filteredIcons = filterIconsByCaption(captionKeyword: "The Resurrection of")
        self.icons = removeIconsWithCaption(icons: self.icons, phrase: "The Resurrection of")
        //self.icons.append(contentsOf: self.filteredIcons)
        //self.icons.removeFirst(2)
    }
    
    func removeIconsWithCaption(icons: [IconModel], phrase: String) -> [IconModel] {
        return icons.filter { !($0.caption?.localizedCaseInsensitiveContains(phrase) ?? false) }
    }
    
    func retrievePassages() {
        passages = readings.compactMap { $0.subSections }.flatMap{ $0 }.compactMap { $0.readings }.flatMap { $0 }.compactMap { $0.passages }.flatMap { $0 }
    }
    
    func formattedDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        let day = formatter.string(from: date)
        formatter.dateFormat = "MMMM"
        let month = formatter.string(from: date)
        formatter.dateStyle = .long
        return "\(day) \(month)"
    }
    
    var copticDate: String {
        Date.copticDate()
    }
    
    var fastView: String {
        isShowingFeastName ? feastName ?? "" : liturgicalInformation ?? ""
    }
    
    func filterIconsByCaption(captionKeyword: String) -> [IconModel] {
        return icons.filter { $0.caption?.contains(captionKeyword) == true }
    }
    
    func updateIconsWithFilteredIcons() {
        for filteredIcon in filteredIcons {
            // Find index of icon with same caption in icons array
            if let index = icons.firstIndex(where: { $0.caption == filteredIcon.caption }) {
                // Replace the icon in icons array with filteredIcon
                icons[index] = filteredIcon
            } else {
                // If no icon with same caption found, add the filteredIcon to icons array
                icons.append(filteredIcon)
            }
        }
    }
    
    func filterAndUpdateIconsByCaption(captionKeyword: String) {
        filteredIcons = filterIconsByCaption(captionKeyword: captionKeyword)
        updateIconsWithFilteredIcons()
    }
    
}



