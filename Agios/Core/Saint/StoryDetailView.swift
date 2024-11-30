//
//  StoryDetailView.swift
//  Agios
//
//  Created by Victor on 6/6/24.
//

import SwiftUI

struct StoryDetailView: View {
    let story: Story
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var vm: OccasionsViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()
            
            Rectangle()
                .fill(LinearGradient(colors: [.primary300, .clear], startPoint: .top, endPoint: .bottom))
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 0) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .frame(width: 40, height: 5)
                    .foregroundColor(.primary400)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                }, label: {
//                    NavigationButton(labelName: .close, backgroundColor: .primary100, foregroundColor: .primary1000)
//                })
//                .padding(.horizontal, vm.filteredIcons.count > 1 ? 16 : 20)
//                .padding(.top, 24)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text(formatTitleText(story.saint ?? "Title"))
                            .font(.title)
                            .foregroundStyle(.gray900)
                            .fontWeight(.semibold)
                        
                        Text(formatStoryText(story.story ?? "story"))
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(.gray700)
                    }
                    .padding(.horizontal, vm.filteredIcons.count > 0 ? 16 : 20)
                    .textSelection(.enabled)
                    .fontDesign(.rounded)
                    .padding(.top, 48)
                    .padding(.bottom, 24)
                }
            }
            //.padding(.top, 24)
        }
        .kerning(-0.4)
    }
    private func formatStoryText(_ storyText: String) -> String {
        return storyText.replacingOccurrences(of: "\n", with: "\n\n")
    }
    private func formatTitleText(_ storyText: String) -> String {
        return storyText.replacingOccurrences(of: "\n", with: "")
    }
}

#Preview {
    StoryDetailView(story: dev.story)
        .environmentObject(OccasionsViewModel())
}
