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
    let date: String
    var urlLink: String
    var customDate: Date
    var name: String
}

class OccasionsViewModel: ObservableObject {
    @Published var icons: [IconModel] = []
    @Published var selectedCopticDate: DateModel? = nil
    @Published var filteredIcons: [IconModel] = []
    @Published var stories: [Story] = []
    @Published var readings: [DataReading] = []
    var liturgy: DataReading?
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
    @Published var stopDragGesture: Bool = false
    @Published var disallowTapping: Bool = false
    @Published var showUpcomingView: Bool = false
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
    @Published var showImageView: Bool = false
    @Published var showStory: Bool = false
    @Published var feast: String = "" {
        didSet {
            updateMockDates()
        }
    }
    @Published var datePicker: Date = Date() {
        didSet {
            filterDate()
        }
    }
    
    @Published var mockDates: [DateModel] = []
    @Published var selectedMockDate: DateModel? = nil
    var copticEvents: [CopticEvent]?
    var feastName: String?
    var liturgicalInformation: String?
    var occasionName: String {
        dataClass?.name ?? "Unknown Occasion"
    }
    
    private weak var task: URLSessionDataTask?
    @Published var filteredDate: [DateModel] = []
    
    init() {
        withAnimation {
            self.isLoading = true
        }
        getCopticEvents()
        updateMockDates()
        handleChangeInUrl()
        
    }
    
    private func loadJSONFromFile(fileName: String)  {
        // Get the path for the JSON file
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            print("Invalid file path.")
            return
        }

        do {
            // Read the data from the file
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            
            // Decode the data to an array of CopticEvent
            copticEvents = try JSONDecoder().decode([CopticEvent].self, from: data)
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
    
    private func getCopticEvents() {
       loadJSONFromFile(fileName: "copticEvents")
    }
    
    private func updateMockDates() {
        mockDates = [
            DateModel(month: "\(newCopticDate?.month ?? "")", day: "27", date: "2024-04-21T12:00:00.000Z", urlLink: "0a5iojkoqj5ktgn", customDate: Date.from(year: 2024, month: 4, day: 21), name: "Departure of Lazarus the Beloved of the Lord"),
            DateModel(month: "\(newCopticDate?.month ?? "")", day: "30", date: "2024-06-07T00:00:00.000Z", urlLink: "sksglsm92ae42x9", customDate: Date.from(year: 2024, month: 6, day: 7), name: "Fifth Week of the Holy Fifty Days")
        ]
    }
    
    func filterDate() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
            selectedCopticDate = filteredDate.first
            self.feast = selectedCopticDate?.name ?? "Fifth Week of the Holy Fifty Days"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
                withAnimation {
                    self.isLoading = true
                    self.getPosts()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.88)) {
                    self.defaultDateTapped = false
                }
            }
        }
    }
    
    func copticDate(for date: Date) -> String {
        let calendar = Calendar(identifier: .coptic)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let monthName = calendar.monthSymbols[month - 1]

        return "\(monthName) \(day)"
    }
    
    var occasionID: String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let formattedDate = formatter.string(from: datePicker)
        if let event = copticEvents?.first(where: { $0.date == formattedDate }) {
            return event.occasionID
        }
        return nil
    }
    
    func getPosts() {
        guard let url = URL(string: "https://api.agios.co/occasions/get/\(selectedCopticDate?.urlLink ?? "sksglsm92ae42x9")") else { return }
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                let decodedResponse = try handleOutput(response: response, data: data)
                    await updateUI(with: decodedResponse)
            } catch {
                print("Error fetching data: \(error)")            }
        }
    }
    
    func handleOutput(response: URLResponse, data: Data) throws -> Response {
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }
    
    @MainActor
    func updateUI(with response: Response) {
        withAnimation(.spring(response: 0.07, dampingFraction: 0.9, blendDuration: 1)) {
            self.isLoading = false
        }
        
        self.icons = response.data.icons ?? []
        self.stories = response.data.stories ?? []
        self.readings = response.data.readings?.filter { $0.title != "Liturgy"} ?? []
        self.liturgy = response.data.readings?.first { $0.title == "Liturgy" }
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
        
        self.subSection = readings.flatMap { $0.subSections ?? [] }
        for story in self.stories {
            self.highlight = story.highlights ?? []
        }
        
        self.filteredIcons = filterIconsByCaption(captionKeyword: "The Resurrection of")
        self.icons = removeIconsWithCaption(icons: self.icons, phrase: "The Resurrection of")
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
            if let index = icons.firstIndex(where: { $0.caption == filteredIcon.caption }) {
                icons[index] = filteredIcon
            } else {
                icons.append(filteredIcon)
            }
        }
    }
    
    func filterAndUpdateIconsByCaption(captionKeyword: String) {
        filteredIcons = filterIconsByCaption(captionKeyword: captionKeyword)
        updateIconsWithFilteredIcons()
    }
    
    func filterIconsByCaption(icons: [IconModel], captionKeyword: String) -> [IconModel] {
        return icons.filter { $0.caption?.contains(captionKeyword) == true }
    }
    
    func getStory(forIcon icon: IconModel) -> Story? {
        guard let storyID = icon.story?.first else { return nil }
        return stories.first { $0.id == storyID }
    }
    
    func handleChangeInUrl() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.88)) {
            self.defaultDateTapped = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation {
                self.isLoading = true
                self.getPosts()
            }
            self.datePicker = self.selectedCopticDate?.customDate ?? Date()
            self.feast = self.selectedMockDate?.name ?? "Fifth Week of the Holy Fifty Days"
        }
    }
        
    func formattedDate(from dateString: String) -> String? {
        let inputFormatter = ISO8601DateFormatter()
        guard let date = inputFormatter.date(from: dateString) else { return nil }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMMM yyyy"
        return outputFormatter.string(from: date)
    }
    
    func formatDateStringToRelativeDay(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        guard let date = dateFormatter.date(from: dateString) else { return dateString }
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            dateFormatter.dateFormat = "E, d MMM"
            return dateFormatter.string(from: date)
        }
    }
    
    func formatDateStringToFullDate(dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard let date = inputFormatter.date(from: dateString) else {
            return "–"
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMMM yyyy"
        
        return outputFormatter.string(from: date)
    }
    
    func formatDateStringToShortDate(dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard let date = inputFormatter.date(from: dateString) else {
            return "–"
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMM ''yy"
        
        return outputFormatter.string(from: date)
    }
    
    func formatDateStringToTime(dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard let date = inputFormatter.date(from: dateString) else {
            return "–"
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mma"
        outputFormatter.amSymbol = "am"
        outputFormatter.pmSymbol = "pm"
        
        return outputFormatter.string(from: date).lowercased()
    }
}

