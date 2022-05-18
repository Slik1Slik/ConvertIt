//
//  CurrencyTableViewCell.swift
//  ConvertIt
//
//  Created by Slik on 08.05.2022.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {
    
    static let reuseID = "CurrencyTableViewCell"
    
    var state: RowState = .unselected {
        didSet {
            markImageView.tintColor = state == .selected ? .link : .clear
        }
    }
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 6
        
        return imageView
    }()
    
    private let primaryLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 1
        label.textAlignment = .left
        if #available(iOS 14.0, *) {
            label.font = UIFont.preferredFont(from: .headline)
        } else {
            label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        }
        label.textColor = .label
        
        return label
    }()
    
    private let secondaryLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 1
        label.textAlignment = .left
        if #available(iOS 14.0, *) {
            label.font = UIFont.preferredFont(from: .caption)
        } else {
            label.font = UIFont.systemFont(ofSize: 13)
        }
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    private let markImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
        
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .clear
        
        return imageView
    }()
    
    private let primaryLabelFont: UIFont = {
        if #available(iOS 14.0, *) {
            return UIFont.preferredFont(from: .body)
        } else {
            return UIFont.systemFont(ofSize: 17)
        }
    }()
    
    private let secondaryLabelFont: UIFont = {
        if #available(iOS 14.0, *) {
            return UIFont.preferredFont(from: .caption)
        } else {
            return UIFont.systemFont(ofSize: 12)
        }
    }()
    
    private let padding: CGFloat = 20
    private let contentInset: CGFloat = 8
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconImageView.frame = CGRect(x: padding,
                                     y: contentInset,
                                     width: self.frame.height - contentInset * 2,
                                     height: self.frame.height - contentInset * 2)
        
        primaryLabel.frame = CGRect(x: iconImageView.frame.width + padding + contentInset,
                                    y: contentInset,
                                    width: self.frame.width - iconImageView.frame.width - padding * 2,
                                    height: primaryLabelFont.pointSize)
        
        secondaryLabel.frame = CGRect(x: iconImageView.frame.width + padding + contentInset,
                                      y: primaryLabel.frame.height + secondaryLabelFont.pointSize,
                                      width: self.frame.width - iconImageView.frame.width - padding * 2,
                                      height: secondaryLabelFont.pointSize)
        
        markImageView.frame = CGRect(x: self.frame.width - padding - 17,
                            y: contentInset + 17 / 2,
                            width: 17,
                            height: 17)
        
        backgroundColor = UIColor(named: "themeSecondary")
    }
    
    func configure(icon: UIImage?, primaryLabelText: String, secondaryLabelText: String) {
        
        self.iconImageView.image = icon
        self.primaryLabel.text = primaryLabelText
        self.secondaryLabel.text = secondaryLabelText
    }
    
    private func addSubviews() {
        addSubview(iconImageView)
        addSubview(primaryLabel)
        addSubview(secondaryLabel)
        addSubview(markImageView)
    }
    
}

enum RowState {
    case selected
    case unselected
}
