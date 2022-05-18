//
//  SystemAppereanceMode.swift
//  ConvertIt
//
//  Created by Slik on 17.05.2022.
//

import UIKit

enum SystemAppereanceMode: Int, CaseIterable {
    case system = 0
    case light = 1
    case dark = 2
    
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system:
            return .unspecified
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .light:
            return "Светлая"
        case .dark:
            return "Темная"
        case .system:
            return "Система"
        }
    }
}
