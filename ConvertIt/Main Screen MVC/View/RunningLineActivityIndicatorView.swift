//
//  RunningLineActivityIndicatorView.swift
//  ConvertIt
//
//  Created by Slik on 12.05.2022.
//

import UIKit

class RunningLineActivityIndicatorView: UIView {
    
    let runningLineLayer = CAShapeLayer()
    
    private(set) var isAnimating: Bool = false {
        didSet {
            if !isAnimating && isAnimationNeededToBeStopped {
                hide()
            }
        }
    }
    
    private var isAnimationNeededToBeStopped: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimating() {
        dropValues()
        self.animateRunningLine()
    }
    
    private func dropValues() {
        runningLineLayer.removeFromSuperlayer()
    }
    
    private func animateRunningLine() {
        
        isAnimating = true
        
        configureRunningLine(with: pathForRunningLine())
        
        self.layer.addSublayer(runningLineLayer)
        
        CATransaction.begin()
        
        CATransaction.setCompletionBlock { [weak self] in
            self?.isAnimating = false
        }
        
        DispatchQueue.main.async {
            self.runningLineLayer.add(self.lineAnimation(), forKey: "lineAnimation")
        }
        
        CATransaction.commit()
    }
    
    private func pathForRunningLine() -> UIBezierPath {
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 130, y: 0))
        path.move(to: CGPoint(x: 155, y: 0))
        path.addLine(to: CGPoint(x: 170, y: 0))
        path.move(to: CGPoint(x: 200, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width, y: 0))
        path.lineWidth = 5
        
        return path
    }
    
    private func configureRunningLine(with path: UIBezierPath) {
        runningLineLayer.path = path.cgPath
        runningLineLayer.fillColor = UIColor.clear.cgColor
        runningLineLayer.strokeColor = UIColor.systemBlue.cgColor
        runningLineLayer.lineWidth = 5
        runningLineLayer.lineCap = .round
    }
    
    private func lineAnimation() -> CAAnimation {
        let showAnimation = CABasicAnimation(keyPath: "strokeEnd")
        showAnimation.fromValue = 0
        showAnimation.duration = 1
        showAnimation.toValue = 1
        showAnimation.isRemovedOnCompletion = false
        
        let hideAnimation = CABasicAnimation(keyPath: "opacity")
        hideAnimation.fromValue = 1
        hideAnimation.duration = 0.7
        hideAnimation.toValue = 0
        hideAnimation.isRemovedOnCompletion = false
        hideAnimation.beginTime = showAnimation.duration
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [showAnimation, hideAnimation]
        animationGroup.repeatCount = Float.infinity
        animationGroup.duration = showAnimation.duration + hideAnimation.duration
        
        return animationGroup
    }
    
    func stopAnimating(waitsAnimationToFinish: Bool = false) {
        if waitsAnimationToFinish {
            isAnimationNeededToBeStopped = true
        } else {
            hide()
        }
    }
    
    private func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: []) { [weak self] in
            self?.layer.opacity = 0
        } completion: { [weak self] _ in
            self?.dropValues()
            self?.layer.opacity = 1
        }
    }
}
