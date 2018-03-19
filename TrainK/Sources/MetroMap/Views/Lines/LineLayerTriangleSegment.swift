//
//  LineLayerTriangleSegment.swift
//  TrainK
//
//  Created by 张之行 on 3/19/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

class LineLayerTriangleSegment: LineLayerSegment {
    private func point(from: CGPoint, to: CGPoint, apart r: CGFloat) -> CGPoint {
        let width = to.x - from.x
        let height = to.y - from.y
        let L = sqrt(width * width + height * height)
        let l = L + r
        return CGPoint(
            x: from.x + (L*width) / l,
            y: from.y + (L*height) / l
        )
    }
    override func draw(on path: UIBezierPath) {
        if let fromNode = segment.from {
            path.move(to: self.lineLayer.mapView.spacedPosition(fromNode.position))
        }
        let targetPoint = self.lineLayer.mapView.spacedPosition(segment.to.position)
        let width = abs(targetPoint.x - path.currentPoint.x)
        let height = abs(targetPoint.y - path.currentPoint.y)
        let xDir:CGFloat = targetPoint.x - path.currentPoint.x > 0 ? 1 : -1
        let yDir:CGFloat = targetPoint.y - path.currentPoint.y > 0 ? 1 : -1
        if width != height && width != 0 && height != 0 {
            let intermediatePoint:CGPoint
            if width > height {
                intermediatePoint = segment.inverse ? CGPoint(
                    x: path.currentPoint.x + height * xDir,
                    y: targetPoint.y
                    ) : CGPoint(
                        x: targetPoint.x - height * xDir,
                        y: path.currentPoint.y
                )
            } else {
                intermediatePoint = segment.inverse ? CGPoint(
                    x: targetPoint.x,
                    y: path.currentPoint.y + width * yDir
                    ) : CGPoint(
                        x: path.currentPoint.x,
                        y: targetPoint.y - width * yDir
                )
            }
            let curveFrom = self.point(from: path.currentPoint, to: intermediatePoint, apart: 10)
            let curveTo = self.point(from: targetPoint, to: intermediatePoint, apart: 10)
            path.addLine(to: curveFrom)
            path.addQuadCurve(to: curveTo, controlPoint: intermediatePoint)
            //path.move(to: curveTo)
            path.addLine(to: targetPoint)
        }
        path.addLine(to: targetPoint)
    }
    
    
}
