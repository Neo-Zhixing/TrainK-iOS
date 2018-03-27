//
//  LineLayerSegment.swift
//  TrainK
//
//  Created by 张之行 on 3/19/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

class LineLayerSegment {
    var segment: Segment
    var targetPoint:CGPoint {
        return segment.to.position
    }
    
    required init(_ segment: Segment) {
        self.segment = segment
    }

    func draw(on path: UIBezierPath) {
        if (path.currentPoint != segment.from.position) {
            path.move(to: segment.from.position)
        }
    }
    func overlapRect(_ rect: CGRect) -> Bool {
        return false
    }
    func endpointOrientation(for node: Node) -> CGFloat? {
        if node == segment.from {
            return angle(from: node.position, to: segment.to.position)
        } else if node == segment.to {
            return angle(from: node.position, to: segment.from.position)
        }
        return nil
    }
}

extension LineLayerSegment: Hashable {
    static func ==(lhs: LineLayerSegment, rhs: LineLayerSegment) -> Bool {
        return lhs.segment == rhs.segment
    }
    
    var hashValue: Int {
        return segment.hashValue
    }
}

class LineLayerDirectSegment:LineLayerSegment {
    override func draw(on path: UIBezierPath) {
        super.draw(on: path)
        path.addLine(to: targetPoint)
    }
    override func overlapRect(_ rect: CGRect) -> Bool {
        return !rect.intersectionsWithLine(segment.from.position, segment.to.position).isEmpty
    }
}

class LineLayerCurveSegment: LineLayerSegment {
    var cornerRadius:CGFloat = 30
    override func draw(on path: UIBezierPath) {
        super.draw(on: path)
        let intermediatePoint = self.segment.inverse ? CGPoint(
            x: path.currentPoint.x,
            y: targetPoint.y
        ) : CGPoint(
            x: targetPoint.x,
            y: path.currentPoint.y
        )
        path.addQuadCurve(to: targetPoint, controlPoint: intermediatePoint)
    }
}

internal func point(from: CGPoint, to: CGPoint, apart r: CGFloat) -> CGPoint {
    let width = to.x - from.x
    let height = to.y - from.y
    let L = sqrt(width * width + height * height)
    let l = L + r
    return CGPoint(
        x: from.x + (L*width) / l,
        y: from.y + (L*height) / l
    )
}

internal func angle(from: CGPoint, to: CGPoint) -> CGFloat {
    let height = to.y - from.y
    let width = to.x - from.x
    if width == 0 {
        return height > 0 ? CGFloat.pi*0.5 : CGFloat.pi*1.5
    }
    let slope = height / width
    var result = atan(slope)
    if width < 0 {
        result += CGFloat.pi
    }
    if (result < 0) { result += 2 * CGFloat.pi }
    return  result
}
