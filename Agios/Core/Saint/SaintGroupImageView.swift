//
//  SaintGroupImageView.swift
//  Agios
//
//  Created by Victor on 6/9/24.
//


import SwiftUI

struct SaintGroupImageView: View {
    
    @StateObject private var viewModel: IconImageViewModel
    let icon: IconModel
    
    init(icon: IconModel) {
        _viewModel = StateObject(wrappedValue: IconImageViewModel(icon: icon))
        self.icon = icon
    }
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
            } else if viewModel.isLoading {
                ProgressView()
                    .background(Color.primary.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                Image("placeholder")
                    .resizable()
                    .scaledToFill()
            }
        }
    }
}

struct SaintGroupImageView_Preview: PreviewProvider {
    static var previews: some View {
        SaintGroupImageView(icon: dev.icon)
    }
}