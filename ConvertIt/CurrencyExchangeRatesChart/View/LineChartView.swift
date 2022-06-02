//
//  LineChartView.swift
//  ConvertIt
//
//  Created by Slik on 02.06.2022.
//

import UIKit

class LineChartView: UIView {
    
    private var lineLayer: CAShapeLayer = CAShapeLayer()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    private func addSubviews() {
        
    }
    
    private func setUpConstraints() {
        
    }
    
    func drawChart(for values: [Double]) {
        
        configureLine(with: linePath(for: values))
        
        self.layer.addSublayer(lineLayer)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.4
        
        DispatchQueue.main.async {
            self.lineLayer.add(animation, forKey: nil)
        }
    }
    
    private func linePath(for values: [Double]) -> UIBezierPath {
        
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 0
        
        let diff = maxValue - minValue
        
        let path = UIBezierPath()
        
        for index in 0..<values.count {
            
            let xStep = self.frame.width / CGFloat(values.count)
            let xPoint = xStep * CGFloat(index + 1)
            
            let yPoint = ((values[index] - minValue) / diff) * frame.height
            
            if index == 0 {
                path.move(to: CGPoint(x: 0, y: 0))
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
}
