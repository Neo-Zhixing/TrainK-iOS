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
        path.move(to: segment.from.position)
    }
    func overlapRect(_ rect: CGRect) -> Bool {
        return false
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
