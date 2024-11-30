//
//  IconService.swift
//  AgiosWidgetExtension
//
//  Created by Nikola Veljanovski on 24.10.24.
//

import Foundation
import UIKit

struct WidgetService {
    enum WidgetServiceError: Error {
        case imageDataCorrupted
    }
    
    private static var cacheImagePath: URL {
        URL.cachesDirectory.appending(path: "saint.png")
    }
    
    private static var cacheDescriptionPath: URL {
        URL.cachesDirectory.appending(path: "agios_description")
    }
    
    static var cachedDescription: String? {
        guard let description = try? String(contentsOf: cacheDescriptionPath, encoding: .utf8) else {
            return nil
        }
        return description
    }
    
    static var cachedIcon: UIImage? {
        guard let imageData = try? Data(contentsOf: cacheImagePath) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    static var cachedIconAvailable: Bool {
        cachedIcon != nil
    }
    
    static var cachedDescriptionAvailable: Bool {
        cachedDescription != nil
    }
    
    static func fetchSaint() async throws -> Saint? {
        guard let url = URL(string: "https://api.agios.co/occasions/get/date/\(WidgetService.date)")
        else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try? JSONDecoder().decode(Response.self, from: data)
            let icon = response?.data.icons?.first
            let description = icon?.caption ?? ""
            var imageUrl: String?
            if let croppedImage = icon?.croppedImage,
               let image = icon?.image {
                if !croppedImage.isEmpty {
                    imageUrl = croppedImage
                } else if !image.isEmpty {
                    imageUrl = image
                }
            }
            
            if let imageUrl, !imageUrl.isEmpty {
                let (imageData, _) = try await URLSession.shared.data(from: URL(string: imageUrl)!)
                guard let image = UIImage(data: imageData) else {
                    throw WidgetServiceError.imageDataCorrupted
                }
                
                Task {
                    try? await WidgetService.cacheImage(imageData)
                    try? await WidgetService.cacheDescription(description)
                }
                
                return Saint(image: image, description: description)
            }
            
            return Saint(image: UIImage(named: "placeholder")!, description: "")
        } catch {
            print("Error fetching icon: \(error)")
            return nil
        }
    }
    
    private static func cacheImage(_ imageData: Data) async throws {
        try imageData.write(to: cacheImagePath)
    }
    
    private static func cacheDescription(_ description: String) async throws {
        try description.write(to: cacheDescriptionPath, atomically: true, encoding: .utf8)
    }
    
     static var date: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
}
