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
    private func intermediatePoints(from: CGPoint, to: CGPoint) -> (CGPoint, CGPoint)? {
        let width = abs(to.x - from.x)
        let height = abs(to.y - from.y)
        if width != height && width != 0 && height != 0 {
            if width > height {
                let dir:CGFloat = to.x - from.x > 0 ? 1 : -1
                let parallelSegmentLength = (width - height) / 2 * dir
                return (
                    CGPoint(x: from.x + parallelSegmentLength, y: from.y),
                    CGPoint(x: to.x - parallelSegmentLength, y: to.y)
                )
            } else {
                let dir:CGFloat = to.y - from.y > 0 ? 1 : -1
                let parallelSegmentLength = (height-width) / 2 * dir
                return (
                    CGPoint(x: from.x, y: from.y + parallelSegmentLength),
                    CGPoint(x: to.x, y: to.y - parallelSegmentLength)
                )
            }
        }
        return nil
    }
    override func draw(on path: UIBezierPath) {
        super.draw(on: path)
        entrancePoint = nil
        exitPoint = nil
        let originPoint = path.currentPoint
        let targetPoint = self.targetPoint
        if let intermediatePoints = self.intermediatePoints(from: originPoint, to: targetPoint) {
            self.entrancePoint = intermediatePoints.0
            self.exitPoint = intermediatePoints.1
            path.addLine(to: point(from: originPoint, to: intermediatePoints.0, apart: self.cornerRadius))
            path.addQuadCurve(to: point(from: intermediatePoints.1, to: intermediatePoints.0, apart: self.cornerRadius), controlPoint: intermediatePoints.0)
            path.addLine(to: point(from: intermediatePoints.0, to: intermediatePoints.1, apart: self.cornerRadius))
            path.addQuadCurve(to: point(from: targetPoint, to: intermediatePoints.1, apart: self.cornerRadius), controlPoint: intermediatePoints.1)
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
    override func endpointOrientation(for node: Node) -> CGFloat? {
        if let intermediatePoints = self.intermediatePoints(from: segment.from.position, to: segment.to.position) {
            if node == segment.from {
                return angle(from: node.position, to: intermediatePoints.0)
            } else if node == segment.to {
                return angle(from: node.position, to: intermediatePoints.1)
            }
        } else {
            return super.endpointOrientation(for: node)
        }
        return nil
    }
}
