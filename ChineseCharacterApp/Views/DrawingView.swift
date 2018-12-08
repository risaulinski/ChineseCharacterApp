//
//  DrawingView.swift
//  Canvas
//
//  Created by Thomas (Tom) Parker on 9/22/18.
//  Copyright © 2018 Tom Parker. All rights reserved.
//


import UIKit

class DrawingView: UIView {

    var lineColor:UIColor!
    var lineWidth:CGFloat!
    var path = UIBezierPath()
    var touchPoint:CGPoint!
    var startingPoint:CGPoint!
    var points:[[Point]] = []
    var strokes = [UIBezierPath]()
    var stroke_number = 0
    
    override func layoutSubviews() {
        self.clipsToBounds = true
        self.isMultipleTouchEnabled = false
        
        lineColor = UIColor.black
        lineWidth = 10
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        strokes.append(path)
        path = UIBezierPath()
        stroke_number += 1
        print("ENDED")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        startingPoint = touch?.location(in: self)
        path = UIBezierPath()
        path.move(to: startingPoint)
        points.append([])
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*let touch = touches.first
        touchPoint = touch?.location(in: self)
        
        path.move(to: startingPoint)
        points.append([])*/
        
         let touch = touches.first
         touchPoint = touch?.location(in: self)
         
         
         path.addLine(to: touchPoint)
         points[points.count - 1].append((Double(touchPoint.x), Double(touchPoint.y)))
         startingPoint = touchPoint
         
         drawShapeLayer()
    }
    
    func drawUserStroke(stroke:[CGPoint], color: UIColor = .black){
        assert(stroke.count > 1, "single point 'stroke' passed to DrawUserStroke")
        path.move(to:stroke[0])
        for st in stroke[1...] {
            path.addLine(to:st)
        }
        drawShapeLayer(color: color)
    }

    
    func drawChar(stroke:String, scale:@escaping (Point) -> Point) {
        func scale2 (x:Point) -> Point {return x}
        path = UIBezierPath(svgPath: stroke, scale: scale)
        drawShapeLayer()
}
    
    func drawShapeLayer(color: UIColor = .black) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(shapeLayer)
        self.setNeedsDisplay()
    }
    
    func clearCanvas() {
        if (strokes != []) {
            strokes[strokes.count - 1].removeAllPoints()
            //self.layer.sublayers?.remove(at: layer.sublayers!.count - 1)

        }
        //self.layer.sublayers?.removeAll()
        //[self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)]

        self.layer.sublayers = nil
        self.setNeedsDisplay()
        stroke_number = 0
        strokes = []
        points = []
    }
    
    func getPoints() -> [[Point]] {
        return points
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
