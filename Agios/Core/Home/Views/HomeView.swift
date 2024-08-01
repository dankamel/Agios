//
//  HomeView.swift
//  Agios
//
//  Created by Victor on 18/04/2024.
//


import SwiftUI
import Shimmer
import Popovers

enum DragPhase {
    case initial
    case unrestricted
}

 
struct HomeView: View {
    
    @State private var tapNategaPlus = false
    @State private var showSynaxars: Bool? = false
    @State private var showReadings: Bool = false
    @State private var tapIcon = false
    @State private var imageTapped = false
    @State private var readingTapped = false
    @State private var isFeastTapped:Bool = false
    @State private var datePicker: Date = .now
    @State private var selectedSaint: IconModel?
    @State private var selectedIcon: IconModel? = nil
    @State private var upcomingFeast: IconModel? = nil
    @State private var showDetailedView: Bool = false
    @State private var showGDView: Bool = false
    @State private var selectedSection: Passage?
    @State private var showImageViewer: Bool = false
    @State private var scaleImage: Bool = false
    @State private var offset: CGSize = .zero
    let iconographer: Iconagrapher
    @State private var selection: Int = 1
    @State private var showStory: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var startValue: CGFloat = 0
    @State private var currentScale: CGFloat = 1.0
    @State private var position: CGSize = .zero
    @State private var hapticsTriggered = false
    @State private var dragPhase: DragPhase = .initial
    
    var namespace: Namespace.ID
    var transition: Namespace.ID
  
    @EnvironmentObject private var occasionViewModel: OccasionsViewModel
    @EnvironmentObject private var iconImageViewModel: IconImageViewModel
    @EnvironmentObject private var imageViewModel: IconImageViewModel
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                ZStack {
                    Color.primary100.ignoresSafeArea()
                    ScrollView {
                        VStack(spacing: 40) {
                            VStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 32) {
                                    VStack(spacing: 28) {
                                        illustration
                                        VStack(spacing: 18) {
                                            fastView
                                            combinedDateView
                                            
                                        }
                                    }
                                }
                                VStack(spacing: 18) {
                                    imageView
                                    DailyQuoteView(fact: dev.fact)
                                }
                            }
                            dailyReading
                            upcomingFeasts
                        }
                        .padding(.bottom, 48)
                        .padding(.top, 96)
                        .transition(.scale(scale: 0.95, anchor: .top))
                        .transition(.opacity)
        

                    }
                    .allowsHitTesting(occasionViewModel.disallowTapping ? false : true)
                    .scrollIndicators(.hidden)
                    .scrollDisabled(occasionViewModel.copticDateTapped || occasionViewModel.defaultDateTapped || occasionViewModel.isLoading ? true : false)
                    .scaleEffect(occasionViewModel.defaultDateTapped || occasionViewModel.viewState == .expanded || occasionViewModel.viewState == .imageView ? 0.98 : 1)
                    .blur(radius: occasionViewModel.defaultDateTapped || occasionViewModel.viewState == .expanded || occasionViewModel.viewState == .imageView ? 3 : 0)
                    
                    
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.88)) {
                                occasionViewModel.defaultDateTapped = false
                                occasionViewModel.searchDate = ""
                                occasionViewModel.searchText = false
                                occasionViewModel.isTextFieldFocused = false
                                occasionViewModel.hideKeyboard()
                            }
                        }
                        .opacity(occasionViewModel.defaultDateTapped  ? 1 : 0)
                         
                }
                .fontDesign(.rounded)
                
                ZStack {
                    if occasionViewModel.defaultDateTapped {
                        DateView(transition: transition)
                            .offset(y: -keyboardHeight/2.4)
                            //.transition(.blurReplace)
                    }
                }
                
                
                // This controls switching between the home view and single saint / icon details views.
                ZStack {
                    switch occasionViewModel.viewState {
                    case .expanded:
                        DetailLoadingView(icon: $selectedIcon, story: occasionViewModel.getStory(forIcon: selectedIcon ?? dev.icon) ?? dev.story, namespace: namespace)
                            //.transition(.opacity)
                            //.transition(.scale(scale: 1))
                            .scaleEffect(1 + startValue)
                            .offset(x: startValue > 0.2 ? offset.width + position.width : .zero, y: startValue > 0 ? offset.height + position.height : .zero)
                            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("MagnifyGestureScaleChanged"))) { obj in
                                if let scale = obj.object as? CGFloat {
                                    withAnimation {
                                        currentScale = scale
                                    }
                                }
                            }
                            .offset(offset)
                            .scaleEffect(getScaleAmount())
                            .simultaneousGesture(
                                !occasionViewModel.stopDragGesture ?
                                DragGesture()
                                    .onChanged { value in
                                        let dragThreshold: CGFloat = 100

                                        switch dragPhase {
                                        case .initial:
                                            if abs(value.translation.width) > abs(value.translation.height) && value.translation.width > 0 {
                                                // Initial phase: restrict to left-to-right dragging
                                                withAnimation {
                                                    offset = CGSize(width: value.translation.width, height: .zero)
                                                }

                                                if abs(value.translation.width) > dragThreshold {
                                                    dragPhase = .unrestricted
                                                    HapticsManager.instance.impact(style: .light)
                                                    hapticsTriggered = true
                                                }
                                            }
                                        case .unrestricted:
                                            // Unrestricted phase: allow dragging in all directions
                                            withAnimation {
                                                offset = value.translation
                                            }

                                            if !hapticsTriggered && (abs(value.translation.width) > dragThreshold || abs(value.translation.height) > dragThreshold) {
                                                HapticsManager.instance.impact(style: .light)
                                                hapticsTriggered = true
                                            }
                                        }
                                    }
                                    .onEnded { value in
                                        let dragThreshold: CGFloat = 100

                                        switch dragPhase {
                                        case .initial:
                                            if value.translation.width > 0 && abs(value.translation.width) > dragThreshold {
                                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                                    occasionViewModel.viewState = .collapsed
                                                    offset = .zero
                                                    selectedSaint = nil
                                                    occasionViewModel.selectedSaint = nil
                                                }
                                                occasionViewModel.disallowTapping = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.62) {
                                                    occasionViewModel.disallowTapping = false
                                                }
                                            } else {
                                                withAnimation(.spring(response: 0.35, dampingFraction: 1)) {
                                                    offset = .zero
                                                }
                                            }
                                        case .unrestricted:
                                            if abs(value.translation.width) > dragThreshold || abs(value.translation.height) > dragThreshold {
                                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                                    occasionViewModel.viewState = .collapsed
                                                    offset = .zero
                                                    selectedSaint = nil
                                                    occasionViewModel.selectedSaint = nil
                                                }
                                                occasionViewModel.disallowTapping = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.62) {
                                                    occasionViewModel.disallowTapping = false
                                                }
                                            } else {
                                                withAnimation(.spring(response: 0.35, dampingFraction: 1)) {
                                                    offset = .zero
                                                }
                                            }
                                        }

                                        // Reset the drag phase and haptics triggered state after dragging ends
                                        dragPhase = .initial
                                        hapticsTriggered = false
                                    }
                                : nil
                            )

                            .environmentObject(occasionViewModel)
                        
                    case .collapsed:
                        EmptyView()
                    case .imageView:
                        GroupedDetailLoadingView(icon: selectedSaint, story: occasionViewModel.getStory(forIcon: occasionViewModel.filteredIcons.first ?? dev.icon) ?? dev.story, selectedSaint: $selectedSaint, namespace: namespace)
                            //.transition(.blurReplace)
                            .transition(.scale(scale: 1))
                            .environmentObject(occasionViewModel)
                    }
                }
                //.transition(.opacity)
                
                Rectangle()
                    .fill(.gray900.opacity(0.3))
                    .opacity(occasionViewModel.showUpcomingView ? 1 : 0)
            }
            .ignoresSafeArea(edges: .all)
  
        }
        .popover(
            present: $occasionViewModel.showUpcomingView,
            attributes: {
                $0.sourceFrameInset = UIEdgeInsets(16)
                $0.position = .relative(
                    popoverAnchors: [
                        .bottom,
                    ]
                )
                $0.dismissal.mode = .dragDown
                $0.blocksBackgroundTouches = true
                $0.presentation.animation = .spring(
                    response: 0.4,
                    dampingFraction: 0.85,
                    blendDuration: 1
                )
                $0.presentation.transition = .move(edge: .bottom)
                $0.dismissal.animation = .spring(
                    response: 0.4,
                    dampingFraction: 0.85,
                    blendDuration: 1
                )
                $0.dismissal.transition = .move(edge: .bottom).combined(with: .opacity)
            }
        ) {
            UpcomingFeastView()
                .environmentObject(occasionViewModel)
        }
        // This controls the keyboard appearance on the search text field in the date picker in a custom way.
        .onAppear {
            occasionViewModel.stopDragGesture = false
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    withAnimation(.spring(response: 0.45, dampingFraction: 1)) {
                        keyboardHeight = keyboardFrame.height
                    }
                }
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                withAnimation(.spring(response: 0.32, dampingFraction: 1)) {
                    keyboardHeight = 0
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        .halfSheet(showSheet: $occasionViewModel.showStory) {
            StoryDetailView(story: occasionViewModel.getStory(forIcon: selectedSaint ?? dev.icon) ?? dev.story)
                .environmentObject(occasionViewModel)
        } onDismiss: {
            selectedSaint = nil
            selectedIcon = nil
        }
    }
    
    private func getScaleAmount() -> CGFloat {
        let max = UIScreen.main.bounds.height / 2
        let currentAmount = abs(offset.width)
        let percentage = currentAmount / max
        let scaleAmount = 1.0 - min(percentage, 0.5) * 0.6
                 
        return scaleAmount
    }
    
    private func segue(icon: IconModel) {
        selectedIcon = icon
        showDetailedView.toggle()
    }
    
    private func gdSegue(icon: IconModel) {
        selectedSaint = icon
        showGDView.toggle()
    }
    
}



struct HomeView_Preview: PreviewProvider {
    
    @Namespace static var namespace
    @Namespace static var transition
    
    static var previews: some View {
        HeroWrapper {
            HomeView(iconographer: dev.iconagrapher, namespace: namespace, transition: transition)
                .environmentObject(OccasionsViewModel())
                .environmentObject(IconImageViewModel(icon: dev.icon))
        }
    }
}

extension HomeView {
    private var combinedDateView: some View {
        ZStack {
            if occasionViewModel.isLoading {
                ShimmerView(heightSize: 32, cornerRadius: 24)
                    .transition(.opacity)
                    .frame(width: 200)
            } else {
                Button(action: {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.88)) {
                        occasionViewModel.defaultDateTapped.toggle()
                    }
                }, label: {
                    HStack(alignment: .center, spacing: 8, content: {
                        Text(occasionViewModel.datePicker.formatted(date: .abbreviated, time: .omitted))
                            .lineLimit(1)
                            .foregroundStyle(.primary1000)
                            .fontWeight(.medium)
                        
                        Rectangle()
                            .fill(.primary600)
                            .frame(width: 1, height: 17)
                        
                        HStack(spacing: 4) {
                            Text("\(occasionViewModel.newCopticDate?.month ?? "") \(occasionViewModel.newCopticDate?.day ?? "")")
                                .lineLimit(1)
                                .foregroundStyle(.primary1000)
                                .frame(width: 100)
                                
                            
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .foregroundStyle(.primary500)
                        }
                        .fontWeight(.medium)
                        
                        
                    })
                    .padding(.vertical, 6)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.primary300)
                            .matchedGeometryEffect(id: "background", in: transition)
                    )
                    .mask({
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .matchedGeometryEffect(id: "mask", in: transition)
                    })

                })

            }
        }
    }
    
    private var fastView: some View {
        ZStack {
            if occasionViewModel.isLoading {
                ShimmerView(heightSize: 54, cornerRadius: 24)
                    .transition(.opacity)
                    .frame(width: 250)
                
            } else {
                ZStack {
                    if occasionViewModel.liturgicalInfoTapped {
                        Text(occasionViewModel.liturgicalInformation ?? "")
                            .blur(radius: occasionViewModel.liturgicalInfoTapped ? 0 : 10)
                    } else {
                        Text(occasionViewModel.feast)
                            .blur(radius: occasionViewModel.liturgicalInfoTapped ? 10 : 0)
                    }
                }
                .font(.title2)
                 .fontWeight(.semibold)
                 .multilineTextAlignment(.center)
                 .foregroundColor(.primary1000)
                 .frame(width: 250)
                 .modifier(TapToScaleModifier())
                 .onTapGesture {
                     withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                         occasionViewModel.liturgicalInfoTapped.toggle()
                     }
                     
                 }
            }
        }
        .padding(.horizontal, 20)
        
    }
    
    private var imageView: some View {
        ZStack {
            if occasionViewModel.isLoading {
                ScrollView(.horizontal) {
                    HStack(spacing: 18) {
                        ForEach(0..<2) { index in
                            ShimmerView(heightSize: 350, cornerRadius: 24)
                                .frame(width: 300, alignment: .leading)
                                .transition(.opacity)
                                .padding(.vertical, 25)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .scrollDisabled(true)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(occasionViewModel.icons) { saint in
                            //HomeSaintImageView(namespace: namespace, icon: saint)
                            CardView(icon: saint, iconographer: dev.iconagrapher, stories: occasionViewModel.getStory(forIcon: saint) ?? dev.story, showImageViewer: $showImageViewer, selectedSaint: $selectedSaint, namespace: namespace)
                                .contextMenu(ContextMenu(menuItems: {
                                    Button {
                                        occasionViewModel.showStory?.toggle()
                                        selectedIcon = saint
                                        selectedSaint = saint
                                    } label: {
                                        if occasionViewModel.getStory(forIcon: saint) != nil {
                                            Label("See story", systemImage: "book")
                                        } else {
                                            Text("No story")
                                        }
                                    }
                                    .disabled((occasionViewModel.getStory(forIcon: saint) != nil) == true ? false : true)
                                }))
                                .allowsHitTesting(occasionViewModel.disallowTapping ? false : true)
                                .scrollTransition { content, phase in
                                    content
                                        .rotation3DEffect(Angle(degrees: phase.isIdentity ? 0 : -10), axis: (x: 0, y: 50, z: 0))
                                        .blur(radius: phase.isIdentity ? 0 : 0.9)
                                        .scaleEffect(phase.isIdentity ? 1 : 0.95)
                                } 
                                
                                .frame(height: 400, alignment: .center)
                                .onTapGesture {
                                    segue(icon: saint)
                                    selectedSaint = saint
                                    occasionViewModel.disallowTapping = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        occasionViewModel.disallowTapping = false
                                    }
                                    withAnimation(.spring(response: 0.25, dampingFraction: 1)) {
                                        occasionViewModel.viewState = .expanded
                                        occasionViewModel.selectedSaint = saint
                                    }
                                    
                                }
                                .opacity(occasionViewModel.selectedSaint == saint ? 0 : 1)
                            
                        }
                         if !occasionViewModel.filteredIcons.isEmpty {
                            // GroupedSaintImageView(selectedSaint: $selectedSaint, showStory: $occasionViewModel.showStory, namespace: namespace)
                             GroupHeroTransitionView(namespace: namespace)
                                 .contextMenu(ContextMenu(menuItems: {
                                     Button {
                                         selectedSaint = occasionViewModel.filteredIcons.first
                                         occasionViewModel.showStory?.toggle()
                                     } label: {
                                         if occasionViewModel.getStory(forIcon: occasionViewModel.filteredIcons.first ?? dev.icon) != nil {
                                             Label("See story", systemImage: "book")
                                         } else {
                                             Text("No story")
                                         }
                                         
                                     }
                                     .disabled((occasionViewModel.getStory(forIcon: occasionViewModel.filteredIcons.first ?? dev.icon) != nil) == true ? false : true)

                                 }))
                                 .frame(height: 400, alignment: .center)
                                 
                         }
                    }
                    //.padding(.top, -24)
                    .padding(.horizontal, 24)
                }
                
            }
        }
    }

    
    private var commemorations: some View {
        ZStack {
            if occasionViewModel.isLoading {
                ProgressView()
                    .padding(16)
                    .lineLimit(6)
                    .background(.lightBlue.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .padding(.bottom, 40)
                    .padding(.horizontal, 16)
            } else {
                VStack(alignment: .leading, spacing: 16) {
                     Text("Commemorations")
                         .font(.system(size: 20, weight: .bold, design: .rounded))
                         .foregroundColor(.black)
                         .padding(.horizontal, 16)
                     HStack(spacing: 16) {
                         if occasionViewModel.readings.isEmpty {
                             // Add an empty view or placeholder here
                             Text("As today is a Major Feast of the Lord, the Synaxarium is not read today.")
                                 .padding(.bottom, 5)
                                 .padding(.horizontal, 16)
                         } else {
                             TabView {
                                 ForEach(occasionViewModel.stories) { story in
                                     Text("\(story.story ?? "")")
                                         .padding(16)
                                         .lineLimit(6)
                                         .background(.white)
                                         .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                         //.scaleEffect(selectedCommemoration == reading ? 1.05 : 1.0)
                                         //.animation(.spring(response: 0.6, dampingFraction: 0.4))
                                         .onTapGesture {
                                             withAnimation() {
                                                 //selectedCommemoration = reading
                                             }
                                             DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                 withAnimation {
                                                     //selectedCommemoration = nil
                                                     //self.reading = reading
                                                     showSynaxars = true
                                                 }
                                             }
                                         }
                                         .padding(.bottom, 40)
                                         .padding(.horizontal, 16)
                                 }
                             }
                             .frame(height: 200)

                         }
                     }
                     .multilineTextAlignment(.center)
                     .font(.title3)
                     .tabViewStyle(.page)
                 }
                .foregroundColor(.black)
            }
        }
    }
    
     private var dailyReading: some View {
         VStack (alignment: .leading, spacing: 8) {
             ZStack {
                 if occasionViewModel.isLoading {
                     ShimmerView(heightSize: 26, cornerRadius: 24)
                         .frame(width: 160)
                         .transition(.opacity)
                 } else {
                     Text("Daily readings")
                         .font(.title2)
                         .fontWeight(.semibold)
                         .foregroundStyle(.gray900)
                 }
             }
             .padding(.leading, 20)
             
             
             ScrollView(.horizontal, showsIndicators: false) {
                 LazyHStack (alignment: .center, spacing: 16) {
                     if occasionViewModel.isLoading {
                         ForEach(0..<5) { index in
                             ShimmerView(heightSize: 80, cornerRadius: 24)
                                 .frame(width: 160)
                                 .transition(.opacity)
                         }
                     } else {
                         ForEach(occasionViewModel.readings) { reading in
                             ForEach(occasionViewModel.passages, id: \.self) { passage in
                                 DailyReadingView(passage: passage, reading: reading, subSection: dev.subSection)
                                     .scaleEffect(selectedSection == passage ? 1.1 : 1.0)
                                     .animation(.spring(response: 0.6, dampingFraction: 0.4))
                                     .onTapGesture {
                                         withAnimation {
                                             selectedSection = passage
                                             DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                 selectedSection = nil
                                                 occasionViewModel.showReading = true
                                             }
                                         }
                                     }
                                     .halfSheet(showSheet: $occasionViewModel.showReading) {
                                         ReadingsView(passage: passage, verse: dev.verses, subSection: dev.subSection)
                                     } onDismiss: {}
                             }
                         }
                     }

                 }
                 .padding(.top, 10)
                 .padding(.bottom, 8)
                 .padding(.horizontal, 20)
             }
         }


     }
     

    
    private var upcomingFeasts: some View {
        VStack (alignment: .leading, spacing: 8) {
            ZStack {
                if occasionViewModel.isLoading {
                    ShimmerView(heightSize: 32, cornerRadius: 24)
                        .frame(width: 160)
                        .transition(.opacity)
                } else {
                    Text("Upcoming feasts")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray900)
                }
            }
            .padding(.leading, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack (alignment: .center, spacing: 16) {
                    ForEach(0..<3) { saint in
                        if occasionViewModel.isLoading {
                            ShimmerView(heightSize: 150, cornerRadius: 24)
                                .frame(width: 260)
                                .transition(.opacity)
                        } else {
                            HStack(spacing: 16) {
                                Rectangle()
                                    .fill(.primary200)
                                    .frame(width: 80, height: 87, alignment: .center)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                VStack(alignment: .leading, spacing: 16, content: {
                                    Text("St. Joseph Father of Emmanuel")
                                        .font(.title3)
                                        .lineLimit(2)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.gray900)
                                        .frame(width: 200, alignment: .leading)
                                    
                                    Text("In 2 days")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.gray700)
                                })
                            }
                            .padding(16)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .modifier(TapToScaleModifier())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    occasionViewModel.showUpcomingView.toggle()
                                }
                            }
                        }

                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 8)
                .padding(.leading, 20)
            }

            
        }
    }
    
    private var illustration: some View {
        VStack(alignment: .center, spacing: 24) {
            HStack {
                Spacer()
                Image("illustration")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 360, height: 54)
                Spacer()
            }
        }
        .frame(maxWidth: 400)
    }
    
}

