//
//  HeroTransitionView.swift
//  Agios
//
//  Created by Victor on 7/11/24.
//

import SwiftUI
import Shimmer

struct HeroTransitionView: View {
    @ObservedObject var occasionViewModel: OccasionsViewModel
    @State private var showImageViewer = false
    @State private var selectedSaint: IconModel? = nil
    var namespace: Namespace.ID
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(occasionViewModel.icons) { icon in
                    CardView(viewModel: occasionViewModel, icon: icon, iconographer: occasionViewModel.iconagrapher ?? dev.iconagrapher, stories: occasionViewModel.getStory(forIcon: icon) ?? dev.story, showImageViewer: $showImageViewer, selectedSaint: $selectedSaint, namespace: namespace)
                    
                }
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
    }
}

/*
 #Preview {
     HeroWrapper {
         HeroTransitionView(icon: dev.icon)
     }
 }
 */

struct CardDetailsView: View {
    @Binding var icon: IconModel?
    let story: Story
    @ObservedObject var vm: OccasionsViewModel
    @State private var showImageViewer = false
    @State private var selectedSaint: IconModel? = nil
    var namespace: Namespace.ID
    
    var body: some View {
        if let icon = icon {
            CardView(
                viewModel: vm,
                icon: icon,
                iconographer: vm.iconagrapher ?? dev.iconagrapher,
                stories: story,
                showImageViewer: $showImageViewer,
                selectedSaint: $selectedSaint,
                namespace: namespace
            )
            
        }
    }
}


struct CardView: View {
    let icon: IconModel
    @State private var showView: Bool = false
    @State private var showTest: Bool = false
    @StateObject var viewModel: IconImageViewModel
    @ObservedObject private var occasionViewModel: OccasionsViewModel
    let iconographer: Iconagrapher
    let stories: Story
    @Binding var showImageViewer: Bool
    @Binding var selectedSaint: IconModel?
    var namespace: Namespace.ID
    
    @State private var offset: CGSize = .zero
    @State private var bottomOffset: CGSize = .zero
    @State private var topOffset: CGSize = .zero
    @State private var position: CGSize = .zero
    @State private var swipeVelocity: CGFloat = 0
    @State private var startValue: CGFloat = 0
    @State private var endValue: CGFloat = 0
    @State private var resetDrag: Bool = false
    @State private var currentScale: CGFloat = 1.0
    @State private var descriptionHeight: Int = 3
    @State private var storyHeight: Int = 2
    @State private var openSheet: Bool? = false
    @State private var scrollViewOffset: CGFloat = 0
    @Environment(\.presentationMode) var presentationMode
    @State private var verticalPosition = 0.0
    @GestureState private var isPressed = false
    @State private var isDragging = false
    
    
    init(viewModel: OccasionsViewModel, icon: IconModel, iconographer: Iconagrapher, stories: Story, showImageViewer: Binding<Bool>, selectedSaint: Binding<IconModel?>, namespace: Namespace.ID) {
        _viewModel = StateObject(wrappedValue: IconImageViewModel(icon: icon))
        self.occasionViewModel = viewModel
        self.iconographer = iconographer
        self.stories = stories
        self._showImageViewer = showImageViewer
        self._selectedSaint = selectedSaint
        self.namespace = namespace
        self.icon = icon
    }
    
    var body: some View {
        ZStack(content: {
            VStack {
                SourceView(id: "\(icon.id)") {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.clear)
                        .background(
                            ZStack {
                                if let image = viewModel.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                } else if viewModel.isLoading {
                                    ZStack {
                                        Image("placeholder")
                                            .resizable()
                                            .scaledToFill()
                                        
                                        ShimmerView(heightSize: 600, cornerRadius: 24)
                                            .transition(.opacity)
                                    }
                                        
                                } else {
                                    ZStack {
                                        ShimmerView(heightSize: 350, cornerRadius: 24)
                                            .frame(width: 300, alignment: .leading)
                                            .transition(.opacity)
                                            .padding(.vertical, 25)
                                    }
                                    .clipShape(Rectangle())
                                }
                            }
                        )
                        .overlay(alignment: .bottom, content: {
                            Text(icon.caption ?? "")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(8)
                                .padding(.horizontal, 3)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray900.opacity(0.8))
                                .opacity(showTest || !viewModel.isLoading ? 0 : 1)
                                .fontDesign(.rounded)
                                .fontWeight(.semibold)
                        })
                        .background(.primary200)
                        .frame(width: 300, height: 350)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .onTapGesture {
                            showView.toggle()
                            
                            withAnimation(.easeIn(duration: 1)) {
                                showTest.toggle()
                            }
                        }
                }
                .allowsHitTesting(viewModel.isLoading ? true : false)
            }
        })
        .fullScreenCover(isPresented: $showView) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: icon.explanation?.isEmpty ?? true ? 24 : 32) {
                            VStack(alignment: .leading, spacing: 32) {
                                if !showImageViewer {
                                  fitImageView
                                } else {
                                    Rectangle()
                                        .fill(.clear)
                                        .frame(height: 420)
                                        .frame(maxWidth: .infinity)
                                }
                                iconCaption
                                    
                            }
                            .padding(.horizontal, 20)
                            
//                            if let explanation = icon.explanation, !explanation.isEmpty {
//                                divider
//                            }
                            //description
                            story
                            //divider
                            //highlights
                        }
                        .kerning(-0.4)
                        .padding(.bottom, 40)
                        .padding(.top, 115)
                        .fontDesign(.rounded)
                        .foregroundStyle(.gray900)
                    }
                    .scrollIndicators(.hidden)
                    .scrollDisabled(verticalPosition > 0)
                    .overlay(alignment: .top) {
                        ZStack(alignment: .center) {
                            VariableBlurView(maxBlurRadius: 15, direction: .blurredTopClearBottom, startOffset: 0)
                                //.blur(radius: 3)
                                .frame(height: 110)
                                .ignoresSafeArea()
                                .gesture(gestureVertical())
                                .offset(y: verticalPosition > 0 ? 0 : (scrollViewOffset > 567 ? currentScrollRecalulated() : 0))
                            customBackButton
                        }
                        
                    }
                    
                        blurredOverlay
                        filledImageView
//                    VStack(spacing: 12) {
//                        Text("\(scrollViewOffset) \(verticalPosition)")
//                        Text("Scroll view when divided: \((scrollViewOffset - 567) * 1)")
//                             
//                    }
//                    .padding()
//                    .background(.white)
                   
                }

               closeButton
                
            }
            
            .ignoresSafeArea()
            .halfSheet(showSheet: $openSheet) {
                StoryDetailView(story: stories, vm: occasionViewModel)
                    .presentationDetents([.medium, .large])
            } onDismiss: {}
            .onAppear {
                withAnimation {
                    showImageViewer = false
                }
               
            }
            .background(
                BackgroundBlurView()
                    .offset(y: verticalPosition > 0 ? 0 : (scrollViewOffset > 567 ? currentScrollRecalulated() : 0))
                    .ignoresSafeArea()
            )
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.primary100)
                    .ignoresSafeArea()
                    .offset(y: verticalPosition > 0 ? 0 : (scrollViewOffset > 567 ? currentScrollRecalulated() : 0))
            )
            
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            //.interactiveDismissDisabled()
            .offset(y: verticalPosition)
            .transition(.slide)
            .animation(.smooth, value: verticalPosition)
            .onChange(of: scrollViewOffset) { oldValue, newValue in
                if scrollViewOffset > 640 {
                    goBack()
                }
            }
        }
        .heroLayer(id: "\(icon.id)", animate: $showView, sourceCornerRadius: 16, destinationCornerRadius: 24) {
            Rectangle()
                .fill(.clear)
                .background(
                    ZStack {
                        if let image = viewModel.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        }
                    }
                )
                
        } completion: { status in
            print(status ? "Open" : "Close")
        }
        .onChange(of: isPressed) { oldValue, pressed in
            if pressed {
                print("changed")
            } else {
                print("ended")
                if verticalPosition > 0 {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        verticalPosition = .zero
                        showView = false
                        goBack()
                    }
                }
                
                if isDragging {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        showImageViewer = false
                        selectedSaint = nil
                        offset = .zero
                        isDragging = false
                    }
                }
            }
        }
    }
    
    private func currentScrollRecalulated() -> CGFloat {
        let offSetValue = ((scrollViewOffset - 567) * 1)
        return offSetValue
    }
    
    
    private func gestureVertical() -> some Gesture {
        return DragGesture(minimumDistance: 0)
            .updating($isPressed) { value, gestureState, _ in
                gestureState = true
            }
            .onChanged { value in
                if value.translation.height > 0 { // Only allow downward dragging
                    verticalPosition = value.translation.height
                }
            }
            .onEnded { value in
                if value.translation.height > 10 && scrollViewOffset > 600 {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        verticalPosition = .zero
                        showView = false
                        goBack()
                    }
                    withAnimation(.easeIn(duration: 0.6)) {
                        showTest = false
                    }
                } else {
                    verticalPosition = .zero
                }
            }
    }

    
    private func getScaleAmount() -> CGFloat {
        let max = UIScreen.main.bounds.height / 2
        let currentAmount = abs(offset.height)
        let percentage = currentAmount / max
        let scaleAmount = 1.0 - min(percentage, 0.5) * 0.75
        
        // Check if the scale amount is below a certain threshold
        if scaleAmount < 0.4 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                showImageViewer = false
                selectedSaint = nil
                occasionViewModel.viewState = .expanded
            }
        }
         
        return scaleAmount
    }

    
    private func getCornerRadius() -> CGFloat {
        let minCornerRadius: CGFloat = 0
        let maxCornerRadius: CGFloat = 80
        let scaleFactor = getScaleAmount()
        return minCornerRadius + (maxCornerRadius - minCornerRadius) * (1 - scaleFactor)
    }
    
    private func calculatePositionDistance() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width / 3
        let currentScale = startValue
        let positionDistance = screenWidth - currentScale
        return positionDistance
    }

    private func goBack() {
        presentationMode.wrappedValue.dismiss()
        selectedSaint = nil
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            occasionViewModel.saintTapped = false
            occasionViewModel.viewState = .collapsed
            occasionViewModel.selectedSaint = nil
        }
        occasionViewModel.disallowTapping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.62) {
            occasionViewModel.disallowTapping = false
        }
        withAnimation(.easeIn(duration: 0.6)) {
            showTest = false
        }
        showView = false
    }
}


extension CardView {
    private var customBackButton: some View {
        ZStack {
            Button {
                goBack()
                
            } label: {
                //NavigationButton(labelName: .back, backgroundColor: .primary300, foregroundColor: .primary1000)
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .frame(width: 40, height: 5)
                    .foregroundColor(.primary400)
                    .padding(.top, 36)
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            .opacity(showImageViewer ? 0 : 1)
        }
        .opacity(getScaleAmount() < 1 || currentScale > 1 ? 0 : 1)
        .zIndex(showImageViewer ? -2 : 0)
        .offset(y: verticalPosition > 0 ? 16 : (scrollViewOffset > 567 ? (16 + currentScrollRecalulated()) : 16))

    }
    
    private var closeButton: some View {
        ZStack {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                    //selectedSaint = nil
                    showImageViewer = false
                    endValue = 0
                    startValue = min(max(startValue, 0), 0.2)
                    //occasionViewModel.showImageView = false
                    selectedSaint = nil
                    //occasionViewModel.viewState = .expanded
                    occasionViewModel.stopDragGesture = false
                }
                
            } label: {
                NavigationButton(labelName: .close, backgroundColor: .primary300, foregroundColor: .primary1000)
                
            }
            .padding(20)
            .opacity(showImageViewer ? 1 : 0)
        }
        .opacity(getScaleAmount() < 1 || currentScale > 1 ? 0 : 1)
        .zIndex(showImageViewer ? 0 : -2)
        .offset(y: 40)

    }
    private var filledImageView: some View {
        ZStack {
            if showImageViewer {
                Rectangle()
                .fill(.clear)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .background(
                    SaintImageView(icon: icon)
                        .matchedGeometryEffect(id: "\(icon.id)", in: namespace)
                        .scaledToFit()
                        .transition(.scale(scale: 1))
                        .zoomable()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                showImageViewer = true
                            }
                        }
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
                            currentScale <= 1 ?
                            DragGesture()
                                .updating($isPressed) { value, gestureState, _ in
                                    gestureState = true
                                }
                                .onChanged({ value in
                                    isDragging = true // Set dragging to true on change
                                    if startValue <= 0 {
                                        withAnimation {
                                            offset = value.translation
                                        }
                                    }
                                    
                                })
                                .onEnded({ value in
                                    isDragging = false // Reset dragging status on end
                                    let dragThreshold: CGFloat = 100
                                    
                                    if abs(value.translation.height) > dragThreshold {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                            showImageViewer = false
                                            //occasionViewModel.viewState = .expanded
                                            selectedSaint = nil
                                            offset = .zero
                                            HapticsManager.instance.impact(style: .light)
                                            occasionViewModel.stopDragGesture = false
                                            //occasionViewModel.showImageView = false
                                        }
                                    } else {
                                        withAnimation(.spring(response: 0.30, dampingFraction: 1)) {
                                            offset = .zero
                                        }
                                    }
                                })
                            : nil
                        )
                )
                .mask({
                    RoundedRectangle(cornerRadius: 0)
                        .matchedGeometryEffect(id: "\(icon.image)", in: namespace)
                })
                

            }
        }
    }
    private var blurredOverlay: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(startValue > 0 ? 1 : getScaleAmount())
                .zIndex(10)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        showImageViewer = false
                        //occasionViewModel.viewState = .expanded
                        endValue = 0
                        startValue = 0
                        //occasionViewModel.showImageView = false
                        occasionViewModel.stopDragGesture = false
                    }
            }
                .allowsHitTesting(startValue > 0 ? false : true)
        }
        .opacity(showImageViewer ? 1 : 0)
    }
    
    
    private var description: some View {
        ZStack {
            if let explanation = icon.explanation, !explanation.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "book.pages")
                            .foregroundStyle(.gray400)
                        
                        Text("Description")
                            .fontWeight(.semibold)
                    }
                    .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(icon.explanation ?? "")
                            .foregroundStyle(.gray400)
                            .fontWeight(.medium)
                            .lineLimit(descriptionHeight)

                        if icon.explanation?.count ?? 0 > 30 {
                            Button(action: {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    descriptionHeight = (descriptionHeight == 3) ? 100 : 3
                                    HapticsManager.instance.impact(style: .soft)
                                    
                                }
                            }, label: {
                                HStack(alignment: .center, spacing: 4) {
                                    Text("See \((descriptionHeight == 3) ? "more" : "less")")
                                        .fontWeight(.semibold)
                                    Image(systemName: (descriptionHeight == 3) ? "chevron.down" : "chevron.up")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                            })
                        }
                        
                    }
                }
                .padding(.horizontal, 20)
                .textSelection(.enabled)

            }
        }

    }
    
    private var story: some View {
       
        ZStack {
            // Check if both selectedSaint and icon do not have a story
            if occasionViewModel.getStory(forIcon: selectedSaint ?? icon) == nil || occasionViewModel.getStory(forIcon: icon) == nil {
                EmptyView()
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .center, spacing: 12) {
//                        Image(systemName: "book")
//                            .foregroundStyle(.gray900)
                        
                        Text(stories.saint ?? "")
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray900)
                            .lineLimit(1)
                            .font(.title3)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text(stories.story ?? "")
                            .foregroundStyle(.gray900.opacity(0.7))
                            .fontWeight(.medium)
                            .lineLimit(storyHeight)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        /*
                         Button {
                             openSheet?.toggle()
                         } label: {
                             HStack(alignment: .center, spacing: 4) {
                                 Text("Read more")
                                     .fontWeight(.semibold)
                                 Image(systemName: "chevron.down")
                                     .font(.caption)
                                     .fontWeight(.semibold)
                             }
                         }
                         */

                    }
                    
                    Divider()
                    Text("See Story")
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.gray900.opacity(0.7))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                .background(Color.primary100)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.gray900.opacity(0.2), lineWidth: 0.7)
                }
                .padding(.horizontal, 20)
                .textSelection(.enabled)
                .onTapGesture {
                    openSheet?.toggle()
                }
                //.shadow(color: .gray200.opacity(0.6), radius: 10, x: 0, y: 8)
                
            }
        }


    }
    
    private var highlights: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "rays")
                    .foregroundStyle(.gray400)
                
                Text("Highlights")
                    .fontWeight(.semibold)
            }
            .font(.title3)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Lorem ipsum dolor sit amet consectetur. Quam malesuada ut magna consectetur. Elementum scelerisque mauris sed maecenas nisi faucibus vitae. Sed mattis sit amet quam. Id mauris.")
                    .foregroundStyle(.gray400)
                    .fontWeight(.medium)
                
                Button(action: {
                    
                }, label: {
                    HStack(alignment: .center, spacing: 4) {
                        Text("Read more")
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                })

                
            }
        }
        .padding(.horizontal, 20)
        .textSelection(.enabled)

    }
    
    private var divider: some View {
        Divider()
            .background(.gray50)
    }
    
    private var fitImageView: some View {
        DestinationView(id: "\(icon.id)") {
            Rectangle()
                .fill(.clear)
                .frame(height: 420)
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        if let image = viewModel.image {
                            Image(uiImage: image)
                                .resizable()
                                .matchedGeometryEffect(id: "\(icon.id)", in: namespace)
                                .scaleEffect(1 + startValue)
                                .scaledToFill()
                                .offset(offset)
                                .scaleEffect(getScaleAmount())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                        showImageViewer = true
                                        occasionViewModel.showImageView = true
                                        occasionViewModel.stopDragGesture = true
                                        
                                    }
                                }

                        }  else if viewModel.isLoading {
                            ZStack {
                                Image("placeholder")
                                    .resizable()
                                    .scaledToFill()
                                
                                ShimmerView(heightSize: 600, cornerRadius: 24)
                                    .transition(.opacity)
                            }
                                
                        }  else {
                            Image("placeholder")
                                .resizable()
                                .scaledToFill()
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .mask({
                    RoundedRectangle(cornerRadius: 24)
                        .matchedGeometryEffect(id: "\(icon.image)", in: namespace)
                })
                
        }
            
        /*
         VStack {}
         .frame(maxWidth: .infinity)
         .frame(height: 420)
         .background(
             SaintImageView(icon: icon)
                 .matchedGeometryEffect(id: "\(icon.id)", in: namespace)
                 .scaledToFill()
                 .transition(.scale(scale: 1))
                 .onTapGesture {
                     withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                         showImageViewer = true
                         occasionViewModel.showImageView = true
                         occasionViewModel.stopDragGesture = true
                         
                     }
                 }
         )
         .mask({
             RoundedRectangle(cornerRadius: 24)
                 .matchedGeometryEffect(id: "\(icon.image)", in: namespace)
         })
         */
        
        
    }
    
    private var iconCaption: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(icon.caption ?? "")
                .font(.title2)
                .fontWeight(.semibold)
                .onScrollViewOffsetChanged { offset in
                    scrollViewOffset = offset
                }
            
            if !(occasionViewModel.iconagrapher == nil) {
                Text("\(occasionViewModel.iconagrapher?.name ?? "None")")
                    .font(.callout)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                    .background(.primary300)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    
            }
            
            
            if !((occasionViewModel.iconagrapher?.name) == nil) {
                
            }
        }
    }
}



