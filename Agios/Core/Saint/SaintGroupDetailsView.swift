//
//  SaintGroupDetailsView.swift
//  Agios
//
//  Created by Victor on 6/9/24.
//

import SwiftUI

struct GroupedDetailLoadingView: View {
    @ObservedObject var viewModel: OccasionsViewModel
    @State var icon: IconModel?
    let story: Story
    @State private var showImageViewer = false
    @Binding var selectedSaint: IconModel?
    var namespace: Namespace.ID
    
    var body: some View {
        if let icon = icon {
            SaintGroupDetailsView(
                viewModel: viewModel,
                icon: icon,
                iconographer: dev.iconagrapher,
                stories: story,
                showImageViewer: $showImageViewer,
                selectedSaint: $selectedSaint,
                namespace: namespace
            )
        }
    }
}

struct SaintGroupDetailsView: View {
    
    @ObservedObject private var occasionViewModel: OccasionsViewModel
    let icon: IconModel
    let iconographer: Iconagrapher
    let stories: Story
    @Binding var showImageViewer: Bool
    @Binding var selectedSaint: IconModel?
    @State var setSaint: IconModel? = nil
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
    @State private var storyHeight: Int = 6
    @State private var openSheet: Bool? = false
    @State private var appear: Bool = false
    @StateObject private var viewModel: IconImageViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(viewModel: OccasionsViewModel,icon: IconModel, iconographer: Iconagrapher, stories: Story, showImageViewer: Binding<Bool>, selectedSaint: Binding<IconModel?>, namespace: Namespace.ID) {
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
        ZStack(alignment: .topTrailing) {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: icon.explanation?.isEmpty ?? true ? 16 : 32) {
                        VStack(alignment: .leading, spacing: 32) {
                            
                            fitImageView

                            iconCaption
                                .padding(.horizontal, 20)
                        }
                        
                        
                        if let explanation = icon.explanation, !explanation.isEmpty {
                            divider
                        }
                        description
                        story
                        //divider
                        //highlights
                    }
                    .kerning(-0.4)
                    .padding(.bottom, 40)
                    .padding(.top, 118)
                    .fontDesign(.rounded)
                    .foregroundStyle(.gray900)
                    
                }
                .overlay(alignment: .top) {
                    ZStack(alignment: .leading) {
                        VariableBlurView(maxBlurRadius: 15, direction: .blurredTopClearBottom, startOffset: 0)
                            .blur(radius: 3)
                            .frame(height: 102)
                            .ignoresSafeArea()
                        customBackButton
                    }
                    
                }

                    blurredOverlay
                    filledImageView
                
   
            }
            
           closeButton
        }
        .halfSheet(showSheet: $openSheet) {
            StoryDetailView(story: stories, vm: occasionViewModel)
        } onDismiss: {}
        .onAppear {
            selectedSaint = nil
        }
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.primary100)
        )
        .mask {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
    }
        //.ignoresSafeArea(.all)
    }
    
    private func getScaleAmount() -> CGFloat {
        let max = UIScreen.main.bounds.height / 2
        let currentAmount = abs(offset.height)
        let percentage = currentAmount / max
        let scaleAmount = 1.0 - min(percentage, 0.5) * 0.75
        
        // Check if the scale amount is below a certain threshold
        if scaleAmount < 0.4 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                //showImageViewer = false
                selectedSaint = nil
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

}


//struct SaintGroupDetailsView_Preview: PreviewProvider {
//    
//    @Namespace static var namespace
//    
//    static var previews: some View {
//        SaintGroupDetailsView(icon: dev.icon, iconographer: dev.iconagrapher, stories: dev.story, showImageViewer: .constant(false), selectedSaint: .constant(dev.icon), namespace: namespace)
//            .environmentObject(dev.occasionsViewModel)
//    }
//}


extension SaintGroupDetailsView {
    private var customBackButton: some View {
        ZStack {
            Button {
                presentationMode.wrappedValue.dismiss()
                selectedSaint = nil
                setSaint = nil
                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                    occasionViewModel.saintTapped = false
                    occasionViewModel.viewState = .collapsed
                    occasionViewModel.selectedSaint = nil
                }
                occasionViewModel.disallowTapping = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.62) {
                    occasionViewModel.disallowTapping = false
                }
                
            } label: {
                NavigationButton(labelName: .back, backgroundColor: .primary300, foregroundColor: .primary1000)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            .opacity(showImageViewer ? 0 : 1)
        }
        .opacity(getScaleAmount() < 1 || currentScale > 1 ? 0 : 1)
        .zIndex(showImageViewer ? -2 : 0)
        .offset(y: 23)
    }
    
        
    private var closeButton: some View {
        ZStack {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                    //selectedSaints = nil
                    endValue = 0
                    startValue = min(max(startValue, 0), 0.2)
                    showImageViewer = false
                    offset = .zero
                    
                }
                selectedSaint = nil
                setSaint = nil
                
            } label: {
                NavigationButton(labelName: .close, backgroundColor: .primary300, foregroundColor: .primary1000)
            }
            .padding(20)
            //.opacity(self.selectedSaints != nil ? 1 : 0)
            .opacity(showImageViewer ? 1 : 0)
        }
        .opacity(getScaleAmount() < 1 || currentScale > 1 ? 0 : 1)
        //.zIndex(selectedSaints != nil ? 0 : -2)
        .zIndex(showImageViewer ? 0 : -2)
        .offset(y: 40)

    }
    private var filledImageView: some View {
        ZStack {
            if showImageViewer {
                VStack {}
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .background(
                    SaintGroupImageView(icon: setSaint ?? dev.icon)
                        .matchedGeometryEffect(id: "\(setSaint?.id ?? "")", in: namespace)
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
                                .onChanged({ value in
                                    if startValue <= 0 {
                                        withAnimation {
                                            offset = value.translation
                                        }
                                    }
                                    
                                })
                                .onEnded({ value in
                                    let dragThreshold: CGFloat = 100
                                    
                                    if abs(value.translation.height) > dragThreshold {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                            showImageViewer = false
                                            //occasionViewModel.viewState = .expanded
                                            //selectedSaints = nil
                                            offset = .zero
                                            HapticsManager.instance.impact(style: .light)
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
                .offset(.zero)

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
                        //self.selectedSaints = nil
                        endValue = 0
                        startValue = 0
                        showImageViewer = false
                    }
                    selectedSaint = nil
                    setSaint = nil
            }
                .allowsHitTesting(startValue > 0 ? false : true)
        }
        //.opacity(self.selectedSaints != nil ? 1 : 0)
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
                        Text(occasionViewModel.filteredIcons.first?.explanation ?? "")
                            .foregroundStyle(.gray400)
                            .fontWeight(.medium)
                            .lineLimit(descriptionHeight)

                        if descriptionHeight > 10 {
                            Button(action: {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    descriptionHeight = 100
                                }
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
                }
                .padding(.horizontal, 20)
                .textSelection(.enabled)

            }
        }

    }
    
    private var story: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: "book")
                        .foregroundStyle(.gray400)
                    
                    Text(stories.saint ?? "")
                        .fontWeight(.semibold)
                        .lineLimit(2)
                }
                .font(.title3)
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text(stories.story ?? "")
                        .foregroundStyle(.gray400)
                        .fontWeight(.medium)
                        .lineLimit(storyHeight)
                    
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

                    
                    
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
            .background(.gray50)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 20)
        .textSelection(.enabled)
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
        ScrollView(.horizontal) {
            LazyHStack(spacing: 16) {
                ForEach(occasionViewModel.filteredIcons.reversed()) { saint in
                    VStack {}
                    .frame(maxWidth: .infinity)
                    .frame(width: 340, height: 460)
                    .background(
                        SaintGroupImageView(icon: saint)
                            .matchedGeometryEffect(id: "\(saint.id)", in: namespace)
                            .scaledToFill()
                            .transition(.scale(scale: 1))
                            .onTapGesture {
                                selectedSaint = saint
                                setSaint = saint
                                print("this is the set saint \(setSaint?.caption)")
                                occasionViewModel.selectedSaint = saint
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    occasionViewModel.showImageView = true
                                    showImageViewer = true
                                    offset = .zero
                                    
                                    
                                }
                            }
                            .opacity(showImageViewer ? 0 : 1)
                    )
                    .mask({
                        RoundedRectangle(cornerRadius: 24)
                            .matchedGeometryEffect(id: "\(saint.image)", in: namespace)
                    })
                        .zIndex(selectedSaint == saint ? 1 : 0)
                        
                        
                }
            }
            .padding(.horizontal, 20)
            
        }
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.hidden)
    }
    
    private var iconCaption: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(icon.caption ?? "")
                .font(.title2)
            .fontWeight(.semibold)
            
            if !(occasionViewModel.filteredIcons.first?.iconagrapher == nil) {
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
