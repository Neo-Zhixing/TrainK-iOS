//
//  LineLayerParallelSegment.swift
//  MetroMap
//
//  Created by 张之行 on 3/25/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

class LineLayerParallelSegment: LineLayerSegment {
    var cornerRadius: CGFloat = 10
    var entrancePoint: CGPoint?
    var exitPoint: CGPoint?
    override func draw(on path: UIBezierPath) {
        super.draw(on: path)
        entrancePoint = nil
        exitPoint = nil
        let width = abs(targetPoint.x - path.currentPoint.x)
        let height = abs(targetPoint.y - path.currentPoint.y)
        if width != height && width != 0 && height != 0 {
            let intermediatePoint1: CGPoint
            let intermediatePoint2: CGPoint
            if width > height {
                let dir:CGFloat = targetPoint.x - path.currentPoint.x > 0 ? 1 : -1
                let parallelSegmentLength = (width - height) / 2 * dir
                
                intermediatePoint1 = CGPoint(x: path.currentPoint.x + parallelSegmentLength, y: path.currentPoint.y)
                intermediatePoint2 = CGPoint(x: targetPoint.x - parallelSegmentLength, y: targetPoint.y)
            } else {
                let dir:CGFloat = targetPoint.y - path.currentPoint.y > 0 ? 1 : -1
                let parallelSegmentLength = (height-width) / 2 * dir
                intermediatePoint1 = CGPoint(x: path.currentPoint.x, y: path.currentPoint.y + parallelSegmentLength)
                intermediatePoint2 = CGPoint(x: targetPoint.x, y: targetPoint.y - parallelSegmentLength)
            }
            self.entrancePoint = intermediatePoint1
            self.exitPoint = intermediatePoint2
            path.addLine(to: point(from: path.currentPoint, to: intermediatePoint1, apart: self.cornerRadius))
            path.addQuadCurve(to: point(from: intermediatePoint2, to: intermediatePoint1, apart: self.cornerRadius), controlPoint: intermediatePoint1)
            path.addLine(to: point(from: intermediatePoint1, to: intermediatePoint2, apart: self.cornerRadius))
            path.addQuadCurve(to: point(from: targetPoint, to: intermediatePoint2, apart: self.cornerRadius), controlPoint: intermediatePoint2)
        }
        path.addLine(to: targetPoint)
    }
    override func overlapRect(_ rect: CGRect) -> Bool {
        if let entrancePoint = self.entrancePoint, let exitPoint = self.exitPoint {
                return !(rect.intersectionsWithLine(segment.from.position, entrancePoint).isEmpty &&
                    rect.intersectionsWithLine(entrancePoint, exitPoint).isEmpty &&
                    rect.intersectionsWithLine(segment.to.position, exitPoint).isEmpty)
            }
        return !rect.intersectionsWithLine(segment.from.position, segment.to.position).isEmpty
    }
}
