//
//  SVGtoPath.swift
//  Canvas
//
//  Created by Krishna Kahn on 10/23/18.
//  Copyright © 2018 Tom Parker. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit
import Darwin

// Multiplying a Point by a scalar.
//infix operator **
//
//func ** (a: Point, b:Double)-> Point {
//    return (b*a.x,b*a.y)
//}

private func * (a: Double, b:Point)-> Point {
    return (b.x*a,a*b.y)
}

private func + (a:Point, b:Point) -> Point {
    return (a.x + b.x, a.y + b.y)
}

private func - (a:Point, b:Point) -> Point {
    return Point(x: a.x - b.x, y: a.y - b.y)
}


private func ^ (a: Double, b: Int) -> Double {
    return pow(a, Double(b))
}

private func nCr (_ a: Int, _ b: Int) -> Int {
    // Choose operator that works when you're choosing from a set less than size 3 ONLY.
    assert(a >= b && a >= 0 && b >= 0)
    assert(a <= 3)
    if b == 0 || a-b==0 {
        return 1
    } else {
        return a
    }
}
//    var prod:Int = 1
//
//    // compute (a!)/(b!)
//    for i in b + 1..<a+1 {
//        prod *= i
//    }
    
    

//private func linear_curve (_ p : [Point], t: Double) -> Point {
//    return ((1 - t) ** p[0]) + (t ** p[1])
//}
//
//func quad_curve(_ p : [Point], t: Double) -> Point {
//    return (1 - t) ** (((1 - t) ** p[0]) + ((2 * (1 - t) * t) ** p[1]) + ((t ^ 2) ** p[2]))
//}
//
//func cubic_curve(_ p: [Point], t: Double) -> Point {
//    let tinv:Double = 1-t
//    // Formula: sum over i from 0 to 3, (t^i) * (1-t)^i * P_i
//    return ((tinv ^ 3) ** p[0])
//           + (((3 * tinv ^ 2) * t) ** p[1])
//           + ((3 * tinv * (t ^ 2)) ** p[2])
//           + ((t ^ 3) ** p[3])
//}
//func curve (p:[Point], bezierFunc: @escaping([Point], Double) -> Point) -> ((Int) -> [Point]) {
//    func calculate (n: Int) -> [Point] {
//        var points:[Point] = []
//        for i in 0..<n {
//            // t is parameter for bezier curve
//            let t:Double = Double(i)/Double(n)
//            points.append(bezierFunc(p, t))
//        }
//        return points
//    }
//    return calculate
//}

func bezier_curve(_ p: [Point],_ t: Double) -> [Point] {
    var sum:[Point] = [p.first!]
    let j = p.count
    // Formula: sum from i=0 to j (t^i) * (1-t)^i * P_i
    for i in 0..<j {
        // If I wanted to use += I'd have to implement it and that's not worth it.
        sum.append((Double(nCr(j,i)) * (1-t) ^ (j-i)) * (t^i) * p[i])
    }
    return sum
}

func get_curve_fn (_ p:[Point]) -> ((Int) -> [Point]) {
    // Takes a list of points and then returns the function to get a bezier curve over N points.
    // Glorified curry
    
    // This made more sense when it was also getting passed a function but it still works.
    func calculate (n: Int) -> [Point] {
        var points:[Point] = []
        for i in 0..<n {
            // t is parameter for bezier curve
            let t:Double = Double(i)/Double(n)
            points += (bezier_curve(p, t))
        }
        return points
    }
    return calculate
}


public class bezierPoints {
    convenience init (svgPath: String) {
        self.init()
        //self.points = get_points(from: SVGPath(svgPath))
    }
    private func to_point(_ CG:[CGPoint]) -> [Point] {
        return CG.map({(pt:CGPoint) -> Point in return (Double(pt.x),Double(pt.y))})
    }

    func get_points(from svgPath: SVGPath) -> [Point]{
        let NUM_POINTS_IN_PATH:Double = 64
        var p: [Point] = []
        var cg: [CGPoint] = []
        var curr:CGPoint = CGPoint(x:0,y:0)
        assert(svgPath.commands.first!.type == .move)
        for command in svgPath.commands {
            switch command.type {
                case .move: break
                case .line: cg = [curr, command.point]
                case .quadCurve: cg = [curr, command.control1,command.point]
                case .cubeCurve: cg = [curr, command.control1,command.control2,command.point]
                case .close: return p + to_point([curr])
            }
            if command.type != .move {
                p += bezier_curve(to_point(cg), NUM_POINTS_IN_PATH)            }
            //p = [curr, command.control1,command.control1,command.point].filter({$0 != nil}).map({(pt:CGPoint) -> Point in return (Double(pt.x),Double(pt.y))})
            curr = command.point
        }
        return [(0,0)]
    }
}
public extension UIBezierPath {
    convenience init (svgPath: String) {
        self.init()
        applyCommands(from: SVGPath(svgPath))
    }
}

private extension UIBezierPath {
    func applyCommands(from svgPath: SVGPath) {
        for command in svgPath.commands {
            switch command.type {
            case .move: move(to: command.point)
            case .line: addLine(to: command.point)
            case .quadCurve: addQuadCurve(to: command.point, controlPoint: command.control1)
            case .cubeCurve: addCurve(to: command.point, controlPoint1: command.control1, controlPoint2: command.control2)
            case .close: close()
            }
        }
    }
}

// MARK: Enums
fileprivate enum Coordinates {
    case absolute
    case relative
}

// MARK: Class
public class SVGPath {
    public var commands: [SVGCommand] = []
    private var builder: SVGCommandBuilder = move
    private var coords: Coordinates = .absolute
    private var increment: Int = 2
    private var numbers = ""
    
    public init (_ string: String) {
        for char in string {
            switch char {
            case "M": use(.absolute, 2, move)
            case "m": use(.relative, 2, move)
            case "L": use(.absolute, 2, line)
            case "l": use(.relative, 2, line)
            case "V": use(.absolute, 1, lineVertical)
            case "v": use(.relative, 1, lineVertical)
            case "H": use(.absolute, 1, lineHorizontal)
            case "h": use(.relative, 1, lineHorizontal)
            case "Q": use(.absolute, 4, quadBroken)
            case "q": use(.relative, 4, quadBroken)
            case "T": use(.absolute, 2, quadSmooth)
            case "t": use(.relative, 2, quadSmooth)
            case "C": use(.absolute, 6, cubeBroken)
            case "c": use(.relative, 6, cubeBroken)
            case "S": use(.absolute, 4, cubeSmooth)
            case "s": use(.relative, 4, cubeSmooth)
            case "Z": use(.absolute, 1, close)
            case "z": use(.absolute, 1, close)
            default: numbers.append(char)
            }
        }
        finishLastCommand()
    }
    
    private func use (_ coords: Coordinates, _ increment: Int, _ builder: @escaping SVGCommandBuilder) {
        finishLastCommand()
        self.builder = builder
        self.coords = coords
        self.increment = increment
    }
    
    private func finishLastCommand () {
        for command in take(SVGPath.parseNumbers(numbers), increment: increment, coords: coords, last: commands.last, callback: builder) {
            commands.append(coords == .relative ? command.relative(to: commands.last) : command)
        }
        numbers = ""
    }
}

// MARK: Numbers
private let numberSet = CharacterSet(charactersIn: "-.0123456789eE")
private let locale = Locale(identifier: "en_US")


public extension SVGPath {
    class func parseNumbers (_ numbers: String) -> [CGFloat] {
        var all:[String] = []
        var curr = ""
        var last = ""
        
        for char in numbers.unicodeScalars {
            let next = String(char)
            if next == "-" && last != "" && last != "E" && last != "e" {
                if curr.utf16.count > 0 {
                    all.append(curr)
                }
                curr = next
            } else if numberSet.contains(UnicodeScalar(char.value)!) {
                curr += next
            } else if curr.utf16.count > 0 {
                all.append(curr)
                curr = ""
            }
            last = next
        }
        
        all.append(curr)
        
        return all.map { CGFloat(truncating: NSDecimalNumber(string: $0, locale: locale)) }
    }
}

// MARK: Commands
public struct SVGCommand {
    public var point:CGPoint
    public var control1:CGPoint
    public var control2:CGPoint
    public var type:Kind
    
    public enum Kind {
        case move
        case line
        case cubeCurve
        case quadCurve
        case close
    }
    
    public init () {
        let point = CGPoint()
        self.init(point, point, point, type: .close)
    }
    
    public init (_ x: CGFloat, _ y: CGFloat, type: Kind) {
        let point = CGPoint(x: x, y: y)
        self.init(point, point, point, type: type)
    }
    
    public init (_ cx: CGFloat, _ cy: CGFloat, _ x: CGFloat, _ y: CGFloat) {
        let control = CGPoint(x: cx, y: cy)
        self.init(control, control, CGPoint(x: x, y: y), type: .quadCurve)
    }
    
    public init (_ cx1: CGFloat, _ cy1: CGFloat, _ cx2: CGFloat, _ cy2: CGFloat, _ x: CGFloat, _ y: CGFloat) {
        self.init(CGPoint(x: cx1, y: cy1), CGPoint(x: cx2, y: cy2), CGPoint(x: x, y: y), type: .cubeCurve)
    }
    
    public init (_ control1: CGPoint, _ control2: CGPoint, _ point: CGPoint, type: Kind) {
        self.point = point
        self.control1 = control1
        self.control2 = control2
        self.type = type
    }
    
    fileprivate func relative (to other:SVGCommand?) -> SVGCommand {
        if let otherPoint = other?.point {
            return SVGCommand(control1 + otherPoint, control2 + otherPoint, point + otherPoint, type: type)
        }
        return self
    }
}

// MARK: CGPoint helpers
private func +(a:CGPoint, b:CGPoint) -> CGPoint {
    return CGPoint(x: a.x + b.x, y: a.y + b.y)
}

private func -(a:CGPoint, b:CGPoint) -> CGPoint {
    return CGPoint(x: a.x - b.x, y: a.y - b.y)
}

// MARK: Command Builders
private typealias SVGCommandBuilder = ([CGFloat], SVGCommand?, Coordinates) -> SVGCommand

private func take (_ numbers: [CGFloat], increment: Int, coords: Coordinates, last: SVGCommand?, callback: SVGCommandBuilder) -> [SVGCommand] {
    var out: [SVGCommand] = []
    var lastCommand:SVGCommand? = last
    
    let count = (numbers.count / increment) * increment
    var nums:[CGFloat] = [0, 0, 0, 0, 0, 0];
    
    for i in stride(from: 0, to: count, by: increment) {
        for j in 0 ..< increment {
            nums[j] = numbers[i + j]
        }
        lastCommand = callback(nums, lastCommand, coords)
        out.append(lastCommand!)
    }
    
    return out
}

// MARK: Mm - Move
private func move (_ numbers: [CGFloat], last: SVGCommand?, coords: Coordinates) -> SVGCommand {
    return SVGCommand(numbers[0], numbers[1], type: .move)
}

// MARK: Ll - Line
private func line (_ numbers: [CGFloat], last: SVGCommand?, coords: Coordinates) -> SVGCommand {
    return SVGCommand(numbers[0], numbers[1], type: .line)
}

// MARK: Vv - Vertical Line
private func lineVertical (_ numbers: [CGFloat], last: SVGCommand?, coords: Coordinates) -> SVGCommand {
    return SVGCommand(coords == .absolute ? last?.point.x ?? 0 : 0, numbers[0], type: .line)
}

// MARK: Hh - Horizontal Line
private func lineHorizontal (_ numbers: [CGFloat], last: SVGCommand?, coords: Coordinates) -> SVGCommand {
    return SVGCommand(numbers[0], coords == .absolute ? last?.point.y ?? 0 : 0, type: .line)
}

// MARK: Qq - Quadratic Curve To
private func quadBroken (_ numbers: [CGFloat], last: SVGCommand?, coords: Coordinates) -> SVGCommand {
    return SVGCommand(numbers[0], numbers[1], numbers[2], numbers[3])
}

// MARK: Tt - Smooth Quadratic Curve To
private func quadSmooth (_ numbers: [CGFloat], last: SVGCommand?, coords: Coordinates) -> SVGCommand {
    var lastControl = last?.control1 ?? CGPoint()
    let lastPoint = last?.point ?? CGPoint()
    if (last?.type ?? .line) != .quadCurve {
        lastControl = lastPoint
    }
    var control = lastPoint - lastControl
    if coords == .absolute {
        control = control + lastPoint
    }
    return SVGCommand(control.x, control.y, numbers[0], numbers[1])
}

// MARK: Cc - Cubic Curve To
private func cubeBroken (_ numbers: [CGFloat], last: SVGCommand?, coords: Coordinates) -> SVGCommand {
    return SVGCommand(numbers[0], numbers[1], numbers[2], numbers[3], numbers[4], numbers[5])
}

// MARK: Ss - Smooth Cubic Curve To
private func cubeSmooth (_ numbers: [CGFloat], last: SVGCommand?, coords: Coordinates) -> SVGCommand {
    var lastControl = last?.control2 ?? CGPoint()
    let lastPoint = last?.point ?? CGPoint()
    if (last?.type ?? .line) != .cubeCurve {
        lastControl = lastPoint
    }
    var control = lastPoint - lastControl
    if coords == .absolute {
        control = control + lastPoint
    }
    return SVGCommand(control.x, control.y, numbers[0], numbers[1], numbers[2], numbers[3])
}

// MARK: Zz - Close Path
private func close (_ numbers: [CGFloat], last: SVGCommand?, coords: Coordinates) -> SVGCommand {
    return SVGCommand()
}