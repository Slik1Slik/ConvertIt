//
//  Buttons.swift
//  ConvertIt
//
//  Created by Slik on 13.05.2022.
//

import UIKit

class DefaultApplicationButton: UIButton {
    
    private var style: ApplicationButtonStyle = .regular
    
    init(style: ApplicationButtonStyle) {
        super.init(frame: .zero)
        
        self.style = style
        
        self.imageView?.clipsToBounds = true
        self.imageView?.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(imageName: String) {
        let image = UIImage(systemName: imageName, withConfiguration: style.symbolConfiguration)
        self.setImage(image, for: .normal)
    }
}

enum ApplicationButtonStyle {
    case extraSmall
    case small
    case regular
    case large
     
    var symbolConfiguration: UIImage.SymbolConfiguration {
        switch self {
        case .extraSmall:
            return UIImage.SymbolConfiguration(pointSize: 17, weight: .regular, scale: .large)
        case .small:
            return UIImage.SymbolConfiguration(pointSize: 24, weight: .regular, scale: .large)
        case .regular:
            return UIImage.SymbolConfiguration(pointSize: 34, weight: .regular, scale: .large)
        case .large:
            return UIImage.SymbolConfiguration(pointSize: 50, weight: .regular, scale: .large)
        }
    }
    
    var pointSize: CGFloat {
        switch self {
        case .extraSmall:
            return 36
        case .small:
            return 36
        case .regular:
            return 50
        case .large:
            return 65
        }
    }
}
