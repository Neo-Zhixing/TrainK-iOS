//
//  Utils.swift
//  TrainK
//
//  Created by 张之行 on 3/20/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x+rhs.x, y: lhs.y+rhs.y)
    }
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x-rhs.x, y: lhs.y-rhs.y)
    }
    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x*rhs, y: lhs.y*rhs)
    }
    static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x/rhs, y: lhs.y/rhs)
    }
}

extension CGSize {
    static func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width*rhs, height: lhs.height*rhs)
    }
    static func /(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width/rhs, height: lhs.height/rhs)
    }
}
extension UIColor {
    convenience init(hex: String) {
        let hexString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner  = Scanner(string: hexString)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0xFF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
}

func intersectionBetweenSegments(_ p0: CGPoint, _ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint) -> CGPoint? {
    var denominator = (p3.y - p2.y) * (p1.x - p0.x) - (p3.x - p2.x) * (p1.y - p0.y)
    var ua = (p3.x - p2.x) * (p0.y - p2.y) - (p3.y - p2.y) * (p0.x - p2.x)
    var ub = (p1.x - p0.x) * (p0.y - p2.y) - (p1.y - p0.y) * (p0.x - p2.x)
    if (denominator < 0) {
        ua = -ua; ub = -ub; denominator = -denominator
    }
    
    if ua >= 0.0 && ua <= denominator && ub >= 0.0 && ub <= denominator && denominator != 0 {
        return CGPoint(x: p0.x + ua / denominator * (p1.x - p0.x), y: p0.y + ua / denominator * (p1.y - p0.y))
    }
    
    return nil
}
extension CGRect {
    func intersectionsWithLine(_ p0:CGPoint, _ p1: CGPoint) -> [CGPoint] {
        let pointA = CGPoint(x: self.minX, y: self.minY)
        let pointC = CGPoint(x: self.maxX, y: self.maxY)
        let pointD = CGPoint(x: self.minX, y: self.maxY)
        let pointB = CGPoint(x: self.maxX, y: self.minY)
        let lineA = (pointA, pointB)
        let lineB = (pointB, pointC)
        let lineC = (pointC, pointD)
        let lineD = (pointD, pointA)
        
        var intersections : [CGPoint] = []
        
        for line in [lineA, lineB, lineC, lineD] {
            if let point = intersectionBetweenSegments(p0, p1, line.0, line.1) {
                intersections.append(point)
            }
        }
        
        return intersections
    }
}
