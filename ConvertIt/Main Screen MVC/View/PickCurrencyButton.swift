//
//  PickCurrencyButton.swift
//  ConvertIt
//
//  Created by Slik on 03.05.2022.
//

import UIKit

class PickCurrencyButton: UIButton {
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    let primaryLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        if #available(iOS 14.0, *) {
            label.font = UIFont.preferredFont(from: .title)
        } else {
            label.font = UIFont.systemFont(ofSize: 28)
        }
        label.textColor = .label
        return label
    }()
    
    let secondaryLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        if #available(iOS 14.0, *) {
            label.font = UIFont.preferredFont(from: .body)
        } else {
            label.font = UIFont.systemFont(ofSize: 17)
        }
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let contentInset: CGFloat = 10
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                highlight()
            } else {
                lowlight()
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        self.backgroundColor = UIColor(named: "themePrimary")
        
        addSubview(iconImageView)
        addSubview(primaryLabel)
        addSubview(secondaryLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconImageView.frame = CGRect(x: contentInset,
                                     y: contentInset,
                                     width: self.frame.width / 5,
                                     height: self.frame.height - contentInset * 2)
        
        primaryLabel.frame = CGRect(x: iconImageView.frame.width + contentInset * 2,
                                    y: contentInset,
                                    width: self.frame.width - iconImageView.frame.width - 25,
                                    height: iconImageView.frame.height / 2)
        
        secondaryLabel.frame = CGRect(x: iconImageView.frame.width + contentInset * 2,
                                      y: iconImageView.frame.height / 2 + 15,
                                      width: self.frame.width - iconImageView.frame.width - contentInset * 2,
                                      height: iconImageView.frame.height / 2)
        
        iconImageView.layer.masksToBounds = true
        iconImageView.contentMode = .scaleToFill
        iconImageView.layer.cornerRadius = 6
        
        self.layer.shadowRadius = 8
        self.layer.shadowOffset = .zero
        self.layer.shadowColor = UIColor(named: "shadow")!.cgColor
        self.layer.shadowOpacity = 0.5
        
        self.layer.cornerRadius = 8
    }
    
    func configure(icon: UIImage?, primaryLabelText: String, secondaryLabelText: String) {
        self.iconImageView.image = icon
        self.primaryLabel.text = primaryLabelText
        self.secondaryLabel.text = secondaryLabelText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
