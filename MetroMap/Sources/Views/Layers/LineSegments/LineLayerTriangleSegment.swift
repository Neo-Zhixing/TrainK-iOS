//
//  LineLayerTriangleSegment.swift
//  TrainK
//
//  Created by 张之行 on 3/19/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

class LineLayerTriangleSegment: LineLayerSegment {
    override var priority: Int {
        return 10
    }
    var cornerRadius: CGFloat = 10
    var intermediatePoint: CGPoint?
    private func intermediatePoint(from: CGPoint, to: CGPoint) -> CGPoint? {
        let width = abs(to.x - from.x)
        let height = abs(to.y - from.y)
        let xDir:CGFloat = to.x - from.x > 0 ? 1 : -1
        let yDir:CGFloat = to.y - from.y > 0 ? 1 : -1
        if width != height && width != 0 && height != 0 {
            if width > height {
                return segment.inverse ? CGPoint(
                    x: from.x + height * xDir,
                    y: to.y
                    ) : CGPoint(
                        x: to.x - height * xDir,
                        y: from.y
                )
            } else {
                return segment.inverse ? CGPoint(
                    x: to.x,
                    y: from.y + width * yDir
                    ) : CGPoint(
                        x: from.x,
                        y: to.y - width * yDir
                )
            }
        }
        return nil
    }
    override func draw(on path: UIBezierPath) {
        super.draw(on: path)
        self.intermediatePoint = nil
        let targetPoint = self.targetPoint
        let originPoint = path.currentPoint
        if let intermediatePoint = intermediatePoint(from: originPoint, to: targetPoint) {
            self.intermediatePoint = intermediatePoint
            let curveFrom = point(from: originPoint, to: intermediatePoint, apart: self.cornerRadius)
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
        guard let intermediatePoint = self.intermediatePoint(from: segment.from.position, to: segment.to.position) else {
            return super.endpointOrientation(for: node)
        }
        return angle(from: node.position, to: intermediatePoint)
    }
}
