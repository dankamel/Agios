//
//  IconImageViewModel.swift
//  Agios
//
//  Created by Victor on 22/04/2024.
//

import Foundation
import SwiftUI
import Combine

class IconImageViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var isLoading: Bool = false
    @Published var allowTapping: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let dataService: IconImageDataService
    
    
    init(icon: IconModel) {
        self.isLoading = true
        self.dataService = IconImageDataService(urlString: icon.image, icon: icon)
        self.addSubscribers()
    }
    
    
    func addSubscribers() {
        dataService.$image
            .sink {[weak self] _ in
                self?.isLoading = false
                self?.allowTapping = false
            } receiveValue: {[weak self] (returnedImage) in
                DispatchQueue.main.async {
                    self?.image = returnedImage
                    self?.allowTapping = true
                }
                
            }
            .store(in: &cancellables)

    }
}






