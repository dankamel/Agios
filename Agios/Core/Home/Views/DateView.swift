//
//  DateView.swift
//  Agios
//
//  Created by Victor on 5/15/24.
//

import SwiftUI
import Lottie

struct DateView: View {
    enum DateSelection: Int, CaseIterable {
       case regularDate
       case feast
       case yearAhead
           
       func title(using viewModel: OccasionsViewModel) -> String {
           switch self {
           case .regularDate:
               return "\(viewModel.datePicker.formatDateShort(viewModel.datePicker))"
           case .feast:
                   return "\(viewModel.newCopticDate?.month ?? "") \(viewModel.newCopticDate?.day ?? "")"
           case .yearAhead:
               return "Year ahead"
           }
       }
       
       @ViewBuilder
       func selectedDate(using viewModel: OccasionsViewModel) -> some View {
           switch self {
           case .regularDate:
                   NormalDateView(vm: viewModel)
           case .feast:
                   FeastView(occasionViewModel: viewModel)
           case .yearAhead:
                   YearAheadView(occasionViewModel: viewModel)
           }
       }
   }
    
    @ObservedObject private var occasionViewModel: OccasionsViewModel
    var transition: Namespace.ID
    @State private var openCopticList: Bool = false
    @State private var datePicker: Date = Date()
    @Environment(\.colorScheme) var colorScheme
    @State private var searchText: Bool = false
    @State private var datedTapped: Bool = false
    @State private var feastTapped: Bool = false
    @State private var yearTapped: Bool = false
    let startingDate: Date = Calendar.current.date(from: DateComponents(year: 2023)) ?? Date()
    
    init(occasionViewModel: OccasionsViewModel, transition: Namespace.ID) {
        self.occasionViewModel = occasionViewModel
        self.transition = transition
    }
    @AppStorage("animationModeKey") private var animationsMode: DateSelection = .regularDate
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .center, spacing: 0) {
                HStack {
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text("Select a date")
                            .fontWeight(.medium)
                            
                    }
                    
                    Spacer()
                       
                }
                .padding(.vertical, 14)
                
                VStack(alignment: .center, spacing: 0) {
                    Divider()
                        .background(.gray50)
                    
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            ForEach(DateSelection.allCases.indices, id: \.self) { index in
                                let mode = DateSelection.allCases[index]

                                Button {
                                    withAnimation {
                                        animationsMode = mode
                                        occasionViewModel.hideKeyboard()
                                    }
                                    
                                } label: {
                                    Text(mode.title(using: occasionViewModel))
                                        .foregroundStyle(animationsMode == mode ? .gray900 : .gray400.opacity(0.7))
                                        .font(.body)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(BouncyButton())
                                
                            }
                        }
                        Divider()
                    }

                    .frame(maxWidth: .infinity)
                    .background {
                        GeometryReader { proxy in
                            let caseCount = DateSelection.allCases.count
                            Rectangle()
                                .fill(.gray900)
                                .frame(height: 1.5)
                                .padding(.top, 40)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(width: proxy.size.width / CGFloat(caseCount))
                                // Offset the background horizontally based on the selected animation mode
                                .offset(x: proxy.size.width / CGFloat(caseCount) * CGFloat(animationsMode.rawValue))
                        }
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.9), value: animationsMode)
                    
                    animationsMode.selectedDate(using: occasionViewModel)
                                            .transition(.opacity.combined(with: .scale(scale: 0.94, anchor: .bottom)).animation(.spring(response: 0.3, dampingFraction: 1)))
                    
                }
                .scaleEffect(openCopticList ? 1 : 0.85, anchor: .top)
                .blur(radius: openCopticList ? 0 : 15)
                .opacity(openCopticList ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 1), value: animationsMode)
            }
            .foregroundStyle(.gray900)
            .fontWeight(.medium)
            .fontDesign(.rounded)
        }
        
        .overlay(alignment: .topLeading) {
            Button {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.88)) {
                    occasionViewModel.defaultDateTapped = false
                    occasionViewModel.searchDate = ""
                    occasionViewModel.searchText = false
                    occasionViewModel.hideKeyboard()
                }
                //HapticsManager.instance.impact(style: .light)
            } label: {
                Image(systemName: "xmark")
                    .fontWeight(.medium)
                    .frame(width: 30, height: 30)
                    .opacity(openCopticList ? 1 : 0)
                    .blur(radius: openCopticList ? 0 : 6)
                    .foregroundStyle(.gray900)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
            }

           
        }
        
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white)
                .matchedGeometryEffect(id: "background", in: transition)
        )
        .mask({
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .matchedGeometryEffect(id: "mask", in: transition)
        })
        .padding(.horizontal, 20)
        .onAppear(perform: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.88)) {
                openCopticList = true
            }
            occasionViewModel.filteredDate = occasionViewModel.mockDates
        })
        .onDisappear(perform: {
           
                openCopticList = false

        })
        
        .onChange(of: occasionViewModel.datePicker) { _, _ in
            occasionViewModel.filterDate()
            HapticsManager.instance.impact(style: .light)
        }
        .environment(\.colorScheme, .light)
        .fontDesign(.rounded)
        .animation(.spring(response: 0.35, dampingFraction: 0.9), value: animationsMode)
        .frame(maxWidth: 400)
    }
    
}

struct NormalDateView: View {
    @ObservedObject private var vm: OccasionsViewModel
    
    init(vm: OccasionsViewModel) {
        self.vm = vm
    }
    var body: some View {
        DatePicker("", selection: $vm.datePicker,
                   in: AppEnvironment.dateRange,
                   displayedComponents: [.date])
        .datePickerStyle(.graphical)
        .environment(\.colorScheme, .light)
        .padding(.horizontal, 16)
        .frame(height: 336, alignment: .top)
        .frame(maxWidth: 350)
        
    }
}

struct FeastView: View {
    @ObservedObject private var occasionViewModel: OccasionsViewModel
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var selectedCopticMonth: CopticMonth? = nil
    
    init(occasionViewModel: OccasionsViewModel) {
        self.occasionViewModel = occasionViewModel
    }
    
    var filteredDates: [CopticMonth] {
        if occasionViewModel.searchDate.isEmpty {
            return occasionViewModel.allCopticMonths
        } else {
            return occasionViewModel.allCopticMonths.filter { date in

                return date.name.lowercased().contains(occasionViewModel.searchDate.lowercased())
            }
        }
    }
    
    var searchedDatesFromAllMonths: [String] {
        let dataSource = !occasionViewModel.allCopticMonths.isEmpty ? occasionViewModel.allCopticMonths : filteredDates
        
        let allDates = dataSource.flatMap { month in
            month.dates.map { date in
                "\(date)"
            }
        }
        
        if occasionViewModel.searchDate.isEmpty {
            return allDates
        } else {
            let searchTerm = occasionViewModel.searchDate.trimmingCharacters(in: .whitespacesAndNewlines)
            return allDates.filter { dateString in
                return dateString.lowercased().contains(searchTerm.lowercased())
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.callout)
                    .foregroundStyle(isTextFieldFocused ? .primary900 : .gray200)
                
                
                TextField("Search", text: $occasionViewModel.searchDate)
                    .foregroundStyle(.gray900)
                    .frame(maxWidth: .infinity)
                    .submitLabel(.search)
                    .focused($isTextFieldFocused)
            }
            .fontWeight(.medium)
            .foregroundStyle(.gray300)
            .padding(.horizontal, 8)
            .padding(.vertical, 9)
            .background(.white)
            .overlay {
                RoundedRectangle(cornerRadius: 32)
                    .stroke(isTextFieldFocused ? .primary900 : .gray200, lineWidth: 1)
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                    occasionViewModel.searchText = true
                    isTextFieldFocused.toggle()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            
            ScrollView {
                ZStack {
                    if occasionViewModel.searchDate.isEmpty {
                        ZStack {
                            ZStack {
                                if selectedCopticMonth == nil {
                                    VStack(spacing: 8) {
                                        ForEach(filteredDates) { date in
                                            Button(action: {
               
                                                withAnimation(.spring(response: 0.25, dampingFraction: 0.88)) {
                                                    selectedCopticMonth = date
                                                    selectedCopticMonth?.id = date.id
                                                    occasionViewModel.selectedCopticMonth = date
                                                    occasionViewModel.selectedCopticMonth?.id = date.id
                                                    print("selected month \(date.name)")

                                                }
                                            }, label: {
                                                HStack {
                                                    Text(date.name)
                                                        .foregroundStyle(.primary1000)
                                                        .lineLimit(1)
                                                    
                                                    Spacer()
                                                    
                                                    HStack(spacing: 8) {
                                                        
                                                        Circle()
                                                            .fill(.primary1000)
                                                            .frame(width: 6, height: 6)
                                                            .opacity(occasionViewModel.selectedCopticMonth?.id == date.id && occasionViewModel.setColor || "\(occasionViewModel.newCopticDate?.month ?? "")" == date.name ? 1 : 0)
                                                           
                                                        Text("\(date.dates.count) days")
                                                            .foregroundStyle(.primary1000)
                                                            .opacity(0.5)

                                                        Image(systemName: "chevron.right")
                                                            .font(.caption2)
                                                            .foregroundStyle(.primary500)
                                                    }
                                                    
                                                }
                                                .fontWeight(.medium)
                                                .padding(.vertical, 9)
                                                .padding(.horizontal, 16)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(.primary100)
                                                .clipShape(RoundedRectangle(cornerRadius: 12, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                        .stroke(Color.primary1000, lineWidth: 0.7)
                                                        .opacity((occasionViewModel.datePicker == occasionViewModel.date(from: date.name) ?? Date()) ? 1 : 0)
                                                }
                                            })
                                            .buttonStyle(BouncyButton())
                                            .padding(.horizontal, 16)
                                        }

                                        
                                    }
                                    .foregroundStyle(.primary1000)
                                    .padding(.vertical, 8)
                                    .padding(.bottom, 30)
                                    .padding(.top, 4)
                                    .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

                                }

                            }

                            
                            ZStack {
                                if selectedCopticMonth != nil {
                                    VStack(alignment: .leading, spacing: 12) {
                                        
                                        HStack(spacing: 8) {
                                            Image(systemName: "chevron.left")
                                                .font(.caption)
                                            
                                            Text(selectedCopticMonth?.name ?? "")
                                                .foregroundStyle(.primary1000)
                                        }
                                        .padding(.horizontal, 16)
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.25, dampingFraction: 0.88)) {
                                                selectedCopticMonth = nil
                                                occasionViewModel.setColor = false
                                            }
                                        }
                                        
                                        VStack(spacing: 8) {
                                            ForEach(selectedCopticMonth?.dates ?? [], id: \.self) { date in
                                                Button {
                                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.88)) {
                                                        occasionViewModel.copticDateTapped = false
                                                        if date.contains("Baouna") {
                                                            let paona = date.replacingOccurrences(of: "Baouna", with: "Paona")
                                                            occasionViewModel.datePicker = occasionViewModel.date(from: paona) ?? Date()
                                                            isTextFieldFocused = false
                                                        } else {
                                                            occasionViewModel.datePicker = occasionViewModel.date(from: date) ?? Date()
                                                            isTextFieldFocused = false

                                                        }
                                                        
                                                        if (occasionViewModel.datePicker == occasionViewModel.date(from: date) ?? Date()) {
                                                            occasionViewModel.setColor = true
                                                        }
                                                        
                                                        print("selected date \(date)")
                                                        
                                                    }
                                                    HapticsManager.instance.impact(style: .light)
                                                } label: {
                                                    HStack {
                                                        Text(date)
                                                            .foregroundStyle(.primary1000)
                                                            .fontWeight(.medium)
                                                            
                                                        Spacer()
                                                        ZStack {
                                                            if date.contains("Baouna") {
                                                                let paona = date.replacingOccurrences(of: "Baouna", with: "Paona")
                                                                if occasionViewModel.datePicker == occasionViewModel.date(from: paona) ?? Date() || "\(occasionViewModel.newCopticDate?.month ?? "") \(occasionViewModel.newCopticDate?.day ?? "")" == date {
                                                                    Image(systemName: "checkmark.circle.fill")
                                                                        .transition(.scale)
                                                                }
                                                            } else if occasionViewModel.datePicker == occasionViewModel.date(from: date) ?? Date() || "\(occasionViewModel.newCopticDate?.month ?? "") \(occasionViewModel.newCopticDate?.day ?? "")" == date {
                                                                Image(systemName: "checkmark.circle.fill")
                                                                    .transition(.scale)
                                                            }
                                                        }
                                                    }
                                                    .padding(.vertical, 9)
                                                    .padding(.horizontal, 16)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .background(.primary100)
                                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))
                                                    .overlay {
                                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                            .stroke(Color.primary1000, lineWidth: 0.7)
                                                            .opacity(occasionViewModel.datePicker == occasionViewModel.date(from: date) ?? Date() || "\(occasionViewModel.newCopticDate?.month ?? "") \(occasionViewModel.newCopticDate?.day ?? "")" == date ? 1 : 0)
                                                    }
                                                    .padding(.horizontal, 16)


                                                }
                                                .buttonStyle(BouncyButton())
                                            }
                                        }
                                        
                                    }
                                    .foregroundStyle(.primary1000)
                                    .padding(.vertical, 8)
                                    .padding(.bottom, 30)
                                    .padding(.top, 4)
                                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .trailing)).combined(with: .opacity))

                                }

                            }
                        }
                    } else {
                        ZStack {
                            if searchedDatesFromAllMonths.isEmpty {
                                VStack(spacing: -8, content: {
                                    LottieView(animation: .named("search-a.json"))
                                        .playbackMode(.playing(.toProgress(1, loopMode: .loop)))
                                        .frame(width: 80, height: 80, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                        .rotationEffect(Angle(degrees: -90))
                                    Text("No results founds")
                                        .fontWeight(.medium)
                                        .fontDesign(.rounded)
                                        .foregroundStyle(.primary600)
                                        .padding(.vertical, 20)
                                         
                                })
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(searchedDatesFromAllMonths, id: \.self) { date in
                                        Button {
                                            withAnimation(.spring(response: 0.25, dampingFraction: 0.88)) {
                                                occasionViewModel.copticDateTapped = false
                                                occasionViewModel.datePicker = occasionViewModel.date(from: date) ?? Date()
                                                isTextFieldFocused = false
                                            }
                                            HapticsManager.instance.impact(style: .light)
                                        } label: {
                                            HStack {
                                                Text(date)
                                                    .foregroundStyle(.primary1000)
                                                    .fontWeight(.medium)
                                                    
                                                Spacer()
                                                ZStack {
                                                    if occasionViewModel.datePicker == occasionViewModel.date(from: date) ?? Date() || "\(occasionViewModel.newCopticDate?.month ?? "") \(occasionViewModel.newCopticDate?.day ?? "")" == date {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .transition(.scale)
                                                    }
                                                }
                                            }
                                            .padding(.vertical, 9)
                                            .padding(.horizontal, 16)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(.primary100)
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .stroke(Color.primary1000, lineWidth: 0.7)
                                                    .opacity(occasionViewModel.datePicker == occasionViewModel.date(from: date) ?? Date() || "\(occasionViewModel.newCopticDate?.month ?? "") \(occasionViewModel.newCopticDate?.day ?? "")" == date ? 1 : 0)
                                            }
                                            .padding(.horizontal, 16)


                                        }
                                        .buttonStyle(BouncyButton())




                                    }
                                }
                                .foregroundStyle(.primary1000)
                                .padding(.vertical, 8)
                                .padding(.bottom, 30)
                                .padding(.top, 4)

                            }
                        }
                        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))

                        
                    }
                }

            }
            .scrollIndicators(.hidden)
            .frame(height: selectedCopticMonth != nil ? 270 : 230, alignment: .top)
        }
    }
}

struct YearAheadView: View {
    @ObservedObject private var occasionViewModel: OccasionsViewModel
    
    init(occasionViewModel: OccasionsViewModel) {
        self.occasionViewModel = occasionViewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(occasionViewModel.yearAheadFeasts) { item in
                            Button(action: {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.88)) {
                                    occasionViewModel.copticDateTapped = false
                                }
                                HapticsManager.instance.impact(style: .light)
                                
                            }, label: {
                                VStack(alignment: .leading, spacing: 7) {
                                    Text(item.feastName)
                                        .foregroundStyle(.primary1000)
                                    
                                    Text(item.dateString)
                                        .font(.callout)
                                        .foregroundStyle(.primary1000.opacity(0.7))
                                        .lineLimit(1)
                                    
                                }
                                .fontWeight(.medium)
                                .padding(.vertical, 9)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.primary100)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/))
                            })
                            .buttonStyle(BouncyButton())
                        }
                        .padding(.horizontal, 16)
                }
                .padding(.vertical, 8)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
            .frame(height: 250, alignment: .top)
            .padding(.top, 8)
        }
    }
}

struct YearAheadFeast: Codable, Identifiable {
    let id: UUID
    let feastName: String
    let dateString: String

    init(feastName: String, dateString: String) {
        self.id = UUID()
        self.feastName = feastName
        self.dateString = dateString
    }

    enum CodingKeys: String, CodingKey {
        case feastName, dateString
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        feastName = try container.decode(String.self, forKey: .feastName)
        dateString = try container.decode(String.self, forKey: .dateString)
        id = UUID()
    }
    
    static let items: [YearAheadFeast] = [
        YearAheadFeast(feastName: "Jonah's Fast", dateString: "10-12 February 2025"),
        YearAheadFeast(feastName: "Start of Lent", dateString: "24 February 2025"),
        YearAheadFeast(feastName: "Holy Week", dateString: "14-19 April 2025"),
        YearAheadFeast(feastName: "Resurrection", dateString: "20 April 2025"),
        YearAheadFeast(feastName: "Ascension", dateString: "29 May 2025"),
        YearAheadFeast(feastName: "Pentecost", dateString: "8 June 2025"),
        YearAheadFeast(feastName: "Start of Apostles' Fast", dateString: "9 June 2025"),
        YearAheadFeast(feastName: "Coptic New Year (Feast of El Nayrouz)", dateString: "11 September 2025"),
        YearAheadFeast(feastName: "The Start of Kiahk", dateString: "10 December 2025")
    ]
}
