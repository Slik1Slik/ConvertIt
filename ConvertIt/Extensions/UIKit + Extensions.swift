//
//  UIKit + Extensions.swift
//  ConvertIt
//
//  Created by Slik on 30.04.2022.
//

import UIKit
import SwiftUI

extension UIStackView {
    func setBackgroundColor(_ color: UIColor?) {
        if #available(iOS 14.0, *) {
            self.backgroundColor = color
        } else {
            let subView = UIView(frame: bounds)
            subView.backgroundColor = color
            subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            insertSubview(subView, at: 0)
        }
    }
}

@available(iOS 14.0, *)
extension UIFont {
    class func preferredFont(from font: Font) -> UIFont {
        let style: UIFont.TextStyle
        switch font {
        case .largeTitle:  style = .largeTitle
        case .title:       style = .title1
        case .title2:      style = .title2
        case .title3:      style = .title3
        case .headline:    style = .headline
        case .subheadline: style = .subheadline
        case .callout:     style = .callout
        case .caption:     style = .caption1
        case .caption2:    style = .caption2
        case .footnote:    style = .footnote
        case .body: fallthrough
        default:           style = .body
        }
        return  UIFont.preferredFont(forTextStyle: style)
    }
}

extension UIView {
    
    func scaleDown(duration: TimeInterval = 0.2) {
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseIn, .allowAnimatedContent, .layoutSubviews], animations: { () -> Void in
            self.transform = CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95)
        })
    }
    
    func returnToIdentity(duration : TimeInterval = 0.2) {
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseOut, .allowAnimatedContent], animations: { () -> Void in
            self.transform = .identity
        })
    }
    
    func highlight(duration: TimeInterval = 0.1) {
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear, .allowAnimatedContent, .layoutSubviews], animations: { () -> Void in
            self.alpha = 0.7
        })
    }
    
    func lowlight(duration: TimeInterval = 0.1) {
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear, .allowAnimatedContent, .layoutSubviews], animations: { () -> Void in
            self.alpha = 1
        })
    }
}

extension UIView {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension UITextField {
    func addBottomBorder(){
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
        bottomLine.backgroundColor = UIColor.separator.cgColor
        borderStyle = .none
        layer.addSublayer(bottomLine)
    }
}

extension CGAffineTransform {
    var translation: CGPoint {
        return CGPoint(x: self.tx, y: self.ty)
    }
}
