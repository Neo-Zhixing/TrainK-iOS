//
//  LineLayerTriangleSegment.swift
//  TrainK
//
//  Created by 张之行 on 3/19/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

class LineLayerTriangleSegment: LineLayerSegment {
    var cornerRadius: CGFloat = 10
    var intermediatePoint: CGPoint?
    override func draw(on path: UIBezierPath) {
        super.draw(on: path)
        self.intermediatePoint = nil
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
            self.intermediatePoint = intermediatePoint
            let curveFrom = point(from: path.currentPoint, to: intermediatePoint, apart: self.cornerRadius)
            let curveTo = point(from: targetPoint, to: intermediatePoint, apart: self.cornerRadius)
            path.addLine(to: curveFrom)
            path.addQuadCurve(to: curveTo, controlPoint: intermediatePoint)
        }
        path.addLine(to: targetPoint)
    }
    override func overlapRect(_ rect: CGRect) -> Bool {
        if let intermediatePoint = self.intermediatePoint {
            return !(rect.intersectionsWithLine(segment.from.position, intermediatePoint).isEmpty && rect.intersectionsWithLine(segment.to.position, intermediatePoint).isEmpty)
        }
        return !rect.intersectionsWithLine(segment.from.position, segment.to.position).isEmpty
    }
    override func endpointOrientation(for node: Node) -> CGFloat? {
        guard let intermediatePoint = self.intermediatePoint else {
            return super.endpointOrientation(for: node)
        }
        return angle(from: node.position, to: intermediatePoint)
    }
}
