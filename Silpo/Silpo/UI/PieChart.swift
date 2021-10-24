//
//  PieChart.swift
//  Silpo
//
//  Created by Prefect on 23.10.2021.
//

import UIKit

class PieChartView: UIView {
    // MARK: - Data
    
    private var data: [(String, CGFloat)] = []
    
    func set(data: [String: Float]) {
        let sum = data.compactMap{ $0.value }.reduce(0, +)
        self.data = sum == 0 ? data.map{ ($0.0, CGFloat($0.1)) } : data.map{ ($0.0, CGFloat($0.1 / sum)) }.sorted(by: { $0.1 > $1.1 })
    }
    
    // MARK: - Initializers
    
    init(frame: CGRect, colors: [UIColor]? = nil, strokeWidth: CGFloat = 0, borderColor: UIColor = .black) {
        super.init(frame: frame)
        
        self.colors = colors ?? self.colors
        self.strokeWidth = strokeWidth
        self.borderColor = borderColor
        
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Aesthetics
    
    var colors: [UIColor] = [UIColor(named: "green")!, UIColor(named: "grey")!]
    var strokeWidth: CGFloat = 0
    var borderColor = UIColor.black
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let center = CGPoint(x: 0.5*rect.width, y: 0.5*rect.height)
        let radius = min(0.5*rect.width, 0.5*rect.height) - 0.5 * strokeWidth
        
        var accumulatedAngle: CGFloat = -0.5 * CGFloat.pi
        var i: Int = 0
        
        borderColor.setStroke()
        context.setLineWidth(strokeWidth)
        
        data.forEach { (key, value) in
            let angle = value * 2 * CGFloat.pi
            
            let path = CGMutablePath()
            path.move(to: CGPoint())
            path.addLine(to: CGPoint(x: radius, y: 0))
            path.addRelativeArc(
                center: CGPoint(),
                radius: radius,
                startAngle: 0,
                delta: angle)
            path.closeSubpath()
            
            context.saveGState()
            
            context.translateBy(x: center.x, y: center.y)
            context.rotate(by: accumulatedAngle)
            
            context.addPath(path)
            colors[i].setFill()
            context.fillPath()
            context.addPath(path)
            context.strokePath()
            
            context.restoreGState()
            
            accumulatedAngle += angle
            i = i >= colors.count ? 0 : i + 1
        }
    }
}
