//
//  CurrencyLabel.swift
//  ConvertIt
//
//  Created by Slik on 08.05.2022.
//

import UIKit

class CurrencyLabel: UIView {
    
    let currencyIcon: UIImageView = UIImageView()
    
    let currencyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        if #available(iOS 14.0, *) {
            label.font = UIFont.preferredFont(from: .title3)
        } else {
            label.font = UIFont.systemFont(ofSize: 20)
        }
        label.textColor = .label
        return label
    }()
    
    private let contentInset: CGFloat = 8
    
    init() {
        super.init(frame: .zero)
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let currencyIconSize = self.frame.height - contentInset * 2
        
        currencyLabel.sizeToFit()
        
        let currencyLabelWidth = currencyLabel.frame.width
        let currencyLabelHeight = currencyIconSize
        
        let currencyIconXPoint = (self.frame.width / 2) - currencyIconSize - contentInset
        let currencyIconYPoint = contentInset
        
        let currencyLabelXPoint = self.frame.width / 2
        let currencyLabelYPoint = contentInset
        
        currencyIcon.frame = CGRect(x: currencyIconXPoint,
                                    y: currencyIconYPoint,
                                    width: currencyIconSize,
                                    height: currencyIconSize)
        
        currencyLabel.frame = CGRect(x: currencyLabelXPoint,
                                     y: currencyLabelYPoint,
                                     width: currencyLabelWidth,
                                     height: currencyLabelHeight)
        
        currencyIcon.layer.masksToBounds = true
        currencyIcon.contentMode = .scaleToFill
        currencyIcon.layer.cornerRadius = currencyIcon.frame.width / 2
        
    }
    
    func configure(icon: UIImage?, label: String) {
        
        self.currencyIcon.image = icon
        self.currencyLabel.text = label
    }
    
    private func addSubviews() {
        addSubview(currencyIcon)
        addSubview(currencyLabel)
    }
}
