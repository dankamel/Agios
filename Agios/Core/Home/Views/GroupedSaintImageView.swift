//
//  GroupedSaintImageView.swift
//  Agios
//
//  Created by Victor on 6/9/24.
//

import SwiftUI

struct GroupedSaintImageView: View {
    @EnvironmentObject private var vm: OccasionsViewModel
    @Binding var selectedSaint: IconModel?
    @Binding var showStory: Bool
    
    var body: some View {
        ZStack {
            ForEach(Array(vm.filteredIcons.enumerated()), id: \.element.id) { index, icon in
                let reversedIndex = vm.filteredIcons.count - index - 1
                HomeSaintImageView(icon: icon)
                    .offset(y: CGFloat(reversedIndex) * -70)
                    .scaleEffect(0.98 - (CGFloat(reversedIndex) * 0.15), anchor: .bottom)
                    .allowsHitTesting(vm.disallowTapping ? false : true)
                    .contextMenu(ContextMenu(menuItems: {
                        Button {
                            selectedSaint = icon
                            showStory.toggle()
                        } label: {
                            if vm.getStory(forIcon: icon) != nil {
                                Label("See story", systemImage: "book")
                            } else {
                                Text("No story")
                            }
                            
                        }
                        .disabled((vm.getStory(forIcon: icon) != nil) == true ? false : true)

                    }))
                    .onTapGesture {
                        selectedSaint = saint
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                            vm.viewState = .imageView
                            vm.selectedSaint = saint
                        }
                        vm.disallowTapping = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            vm.disallowTapping = false
                        }
                    }
                    .opacity(vm.selectedSaint == saint ? 0 : 1)
                    
            }
        }
    }
}

struct GroupedSaintImageView_Previews: PreviewProvider {
    @State static var selectedSaint: IconModel? = nil
    @State static var showStory: Bool = false
    
    static var previews: some View {
        GroupedSaintImageView(selectedSaint: $selectedSaint, showStory: $showStory)
            .environmentObject(OccasionsViewModel())
    }
}


