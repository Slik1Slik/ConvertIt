//
//  LineChartView.swift
//  ConvertIt
//
//  Created by Slik on 02.06.2022.
//

import UIKit

class LineChartView: UIView {
    
    let xStep: CGFloat = 3
    
    var values: [Double] = [] {
        didSet {
            self.minValue = values.min() ?? 0
            self.maxValue = values.max() ?? 0
            self.diff = maxValue - minValue
        }
    }
    
    private var minValue: Double = 0
    private var maxValue: Double = 0
    
    private var diff: Double = 0
    
    private var lineLayer: CAShapeLayer = CAShapeLayer()
    
    private let drawingAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        return animation
    }()
    
    init(frame: CGRect, values: [Double]) {
        super.init(frame: frame)
        
        self.values = values
        self.minValue = values.min() ?? 0
        self.maxValue = values.max() ?? 0
        self.diff = maxValue - minValue
        
        drawChart()
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawChart(animated: Bool = false) {
        
        lineLayer.removeFromSuperlayer()
        
        configureLine(with: linePath())
        
        self.layer.addSublayer(lineLayer)
        self.frame.size = lineLayer.path!.boundingBox.size
        
        if animated {
            lineLayer.add(drawingAnimation, forKey: nil)
        }
    }
    
    private func linePath() -> UIBezierPath {
        
        let path = UIBezierPath()
        
        for index in 0..<values.count {
            
            let xPoint = xStep * CGFloat(index + 1)
            
            let yPoint = ((values[index] - minValue) / diff) * frame.height
            
            if index == 0 {
                path.move(to: CGPoint(x: 0, y: yPoint))
            }
            
            path.addLine(to: CGPoint(x: xPoint, y: yPoint))
        }
        
        path.lineWidth = 1
        
        return path
    }
    
    private func configureLine(with path: UIBezierPath) {
        
        lineLayer.path = path.cgPath
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = UIColor.systemBlue.cgColor
        lineLayer.lineWidth = 1
        lineLayer.lineCap = .round
    }
    
    func point(forIndex index: Int) -> CGPoint {
        let xPoint = xStep * CGFloat(index)
        let yPoint = ((values[index] - minValue) / diff) * frame.height
        
        return CGPoint(x: xPoint, y: yPoint)
    }
}
