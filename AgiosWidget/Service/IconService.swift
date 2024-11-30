//
//  IconService.swift
//  AgiosWidgetExtension
//
//  Created by Nikola Veljanovski on 24.10.24.
//

import Foundation
import UIKit
import WidgetKit

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
    
    static func fetchSaint(for date: Date) async throws -> Saint? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        guard let url = URL(string: "https://api.agios.co/occasions/get/date/\(dateString)") else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try? JSONDecoder().decode(Response.self, from: data)
            
            guard let icon = response?.data.icons?.first else {
                print("No icon data available.")
                return Saint(image: UIImage(named: "placeholder")!, description: "\(date.formatted(date: .abbreviated, time: .omitted))")
            }
            
            let description = icon.caption ?? "\(date.formatted(date: .abbreviated, time: .omitted))"
            
            var imageUrl = ""
            if let croppedImage = icon.croppedImage,
               !croppedImage.isEmpty {
                print("using cropped image")
                imageUrl = croppedImage
            } else {
                print("using full image")
                imageUrl = icon.image
            }
            guard let imageDownloadURL = URL(string: imageUrl),
                  ["jpeg", "jpg", "png"].contains(imageDownloadURL.pathExtension.lowercased()) else {
                print("Image URL is invalid or format is unsupported.")
                return Saint(image: UIImage(named: "placeholder")!, description: description)
            }
            
            // Fetch the image data
            do {
                let (imageData, _) = try await URLSession.shared.data(from: imageDownloadURL)
                guard let image = UIImage(data: imageData) else {
                    throw WidgetServiceError.imageDataCorrupted
                }
                
                Task {
                    try? await WidgetService.cacheImage(imageData)
                    try? await WidgetService.cacheDescription(description)
                }
                
                return Saint(image: image, description: description)
            } catch {
                print("Failed to fetch or decode image data: \(error)")
                return Saint(image: UIImage(named: "placeholder")!, description: description)
            }
        } catch {
            print("Failed to fetch icon data from API: \(error)")
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
