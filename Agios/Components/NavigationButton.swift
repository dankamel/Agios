//
//  NavigationButton.swift
//  Agios
//
//  Created by Victor on 4/25/24.
//

import SwiftUI

enum ButtonLabel: String {
    case back = "chevron.left"
    case close = "xmark"
    case down = "chevron.down"
}

struct NavigationButton: View {
    
    let labelName: ButtonLabel
    let backgroundColor: Color
    let foregroundColor: Color
    
    var body: some View {
        Image(systemName: labelName.rawValue)
            .fontWeight(.semibold)
            .font(.body)
            .foregroundStyle(foregroundColor)
            .padding(12)
            .background(backgroundColor)
            .clipShape(Circle())
    }
}

#Preview {
    NavigationButton(labelName: ButtonLabel.back, backgroundColor: .gray50, foregroundColor: .gray50)
}
