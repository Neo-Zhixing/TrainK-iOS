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
}

class LineLayerDirectSegment:LineLayerSegment {
    override func draw(on path: UIBezierPath) {
        super.draw(on: path)
        path.addLine(to: targetPoint)
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
