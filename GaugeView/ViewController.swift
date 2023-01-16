//
//  ViewController.swift
//  GaugeView
//
//  Created by liam on 14/01/2023.
//

import UIKit
import GLKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let width = 364.0
        let test = iGaugeView.init(frame: .init(x: 0,
                                                y: 0,
                                                width: width,
                                                height: width))
        test.backgroundColor = .clear
        test.translatesAutoresizingMaskIntoConstraints = false
        test.layer.masksToBounds = true
        view.addSubview(test)
        
        NSLayoutConstraint.activate([
            test.widthAnchor.constraint(equalToConstant: width),
            test.heightAnchor.constraint(equalToConstant: width),
            test.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            test.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
      
        
    }
}


class iGaugeView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayers() {
        let outerCircleLayer = OuterCircleLayer.init(view: self)
        self.layer.addSublayer(outerCircleLayer)
        
        let innerCircleLayer = InnerCircleLayer.init(view: self)
        self.layer.addSublayer(innerCircleLayer)
        
        let majorTickLayer = MajorTickLayer(view: self)
        self.layer.addSublayer(majorTickLayer)
    }
}

// MARK: - InnerCircleLayer
class InnerCircleLayer: CAShapeLayer {
    
    private let view: UIView
    
    init(view: UIView){
        self.view = view
        super.init()
        
        fillColor = UIColor.clear.cgColor
        strokeColor = UIColor.black.cgColor
        lineWidth = 1.0
        let ratioInDesign = 134 / 364.0
        path = UIBezierPath(arcCenter: view.center,
                            radius: (view.frame.width * ratioInDesign) / 2.0,
                            startAngle: 0,
                            endAngle: 2 * CGFloat.pi,
                            clockwise: true).cgPath
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - OuterCircleLayer
class OuterCircleLayer : CAShapeLayer {
    var view : iGaugeView

    init(view: iGaugeView) {
        self.view = view
        super.init()
        self.fillColor = UIColor.clear.cgColor
        self.strokeColor = UIColor.black.cgColor
        self.lineWidth = 3
        self.path = UIBezierPath(arcCenter: view.center,
                                 radius: view.frame.width / 2.0 - lineWidth,
                                 startAngle: 0,
                                 endAngle: 2 * CGFloat.pi,
                                 clockwise: true).cgPath
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - MajorTickLayer
class MajorTickLayer : CAShapeLayer {
    struct Settings {
        var minShowableValue: Float = 0.0
        var maxShowableValue: Float = 180.0
        var numberOfMajorTick: Int = 9
        var tickLength: CGFloat = 18.0
    }
    
    var settings = Settings.init()
    var view : iGaugeView
    
    init(view : iGaugeView) {
        self.view = view
        super.init()
        
        
        self.fillColor = UIColor.clear.cgColor
        self.strokeColor = UIColor.black.cgColor
        self.lineWidth = 1
        
        let path = UIBezierPath()
        
        for point in 0..<settings.numberOfMajorTick {
            let degree = getDegreeOnCircleBaseOn(value: Float(point))
            let gaugeRadius = view.frame.width / 2.0 - 3.0
            let startPoint = getPointOnCircle(gaugeRadius - settings.tickLength, degree)
            let endPoint = getPointOnCircle(gaugeRadius, degree)
            
            path.move(to: startPoint)
            path.addLine(to: endPoint)
            
            let textString = String(format: "%i", Int(settings.maxShowableValue / Float(settings.numberOfMajorTick)) * point)
            let textSize = textSize(for: textString, font: .systemFont(ofSize: 16))
            let textCenter = getPointOnCircle(gaugeRadius - ((view.frame.width) * 40.0 / 364.0), degree)
            let textX = textCenter.x - textSize.width / 2.0
            let textY = textCenter.y - textSize.height / 2.0
            
            let textRect = CGRect.init(x: textX, y: textY, width: textSize.width, height: textSize.height)
            
            let textLayer = CATextLayer()
            textLayer.contentsScale = UIScreen.main.scale
            textLayer.frame = textRect
            textLayer.fontSize = 16.0
            textLayer.string = textString
            textLayer.foregroundColor = UIColor.black.cgColor
            
            self.addSublayer(textLayer)
        }
        self.path = path.cgPath
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func textSize(for string: String?, font: UIFont) -> CGSize {
        let attribute = [NSAttributedString.Key.font: font]
        return string?.size(withAttributes: attribute) ?? .zero
    }

    private func getPointOnCircle(_ radius : CGFloat, _ degree : Float) -> CGPoint{
        return CGPoint(x: cos(CGFloat(GLKMathDegreesToRadians(degree)))*radius + view.center.x,
                       y: sin(CGFloat(GLKMathDegreesToRadians(degree)))*radius + view.center.y)
    }
    
    private func getDegreeOnCircleBaseOn(value: Float) -> Float{
        let startAngleDegree: Float = 135.0
        let stopAngleDegree: Float = 405.0
        let totalDegree: Float = stopAngleDegree - startAngleDegree
        let degreeEachSegment = totalDegree / Float(settings.numberOfMajorTick - 1)
        let segmentDegree = value * degreeEachSegment
        let result = segmentDegree
        return result + startAngleDegree
    }
}
