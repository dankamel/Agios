//
//  ImageViewerViewModel.swift
//  Agios
//
//  Created by Victor on 4/29/24.
//

import Foundation
import SwiftUI

class ImageViewerViewModel: ObservableObject {
    @Published var openSaint: Bool = false
    @Published var selectedSaint: IconModel? = nil
    @Published var imageViewerOffset: CGSize = .zero
    @Published var backgroundOpacity: Double = 1
    @Published var imageScaling: Double = 1
    
    
    func onChange(value: CGSize) {
        
        // updating offset
        imageViewerOffset = value
        
        //calculating blur intensity
        let halgHeight = UIScreen.main.bounds.height / 2
        let progress = imageViewerOffset.height / halgHeight
        
        withAnimation(.default) {
            backgroundOpacity = Double(1 - (progress < 0 ? -progress : progress))
        }
    }
    
    func onEnd(value: DragGesture.Value) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 1)) {
            var translation = value.translation.height
            
            if translation <  0 {
                translation = -translation
            }
            
            if translation < 250 {
                imageViewerOffset = .zero
                backgroundOpacity = 1
            } else {
                selectedSaint = nil
                openSaint = false
                imageViewerOffset = .zero
                backgroundOpacity = 1
            }
        }
    }
    
}
