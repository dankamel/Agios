//
//  SaintIconModel.swift
//  Agios
//
//  Created by Victor on 18/04/2024.
//

import SwiftUI
import UIImageColors

struct SaintIconModel: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var textBackgroundColour: UIColor {
        getImageColor().background
    }
    
    var image: UIImage {
        if let img = UIImage(named: name) {
            return img
        } else if let placeholderImg = UIImage(named: "placeholder") {
            return placeholderImg
        } else {
            fatalError("Both main image and placeholder image are missing!")
        }
    }
    
    func getImageColor() -> UIImageColors {
        image.getColors() ?? UIImageColors(background: .black,
                                           primary: .white,
                                           secondary: .black, detail: .blue)
    }
}
