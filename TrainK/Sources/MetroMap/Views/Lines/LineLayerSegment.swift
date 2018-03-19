//
//  LineLayerSegment.swift
//  TrainK
//
//  Created by 张之行 on 3/19/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

class LineLayerSegment {
    var segment: Line.Segment
    weak var lineLayer: LineLayer!
    var targetPoint:CGPoint {
        return self.lineLayer.mapView.spacedPosition(segment.to.position)
    }
    
    required init(_ segment: Line.Segment, onLayer layer: LineLayer) {
        self.segment = segment
        self.lineLayer = layer
    }

    func draw(on path: UIBezierPath) {
        if let fromNode = segment.from {
            path.move(to: self.lineLayer.mapView.spacedPosition(fromNode.position))
        }
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
