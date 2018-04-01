//
//  LineLayerSquareSegment.swift
//  TrainK
//
//  Created by 张之行 on 3/20/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

class LineLayerSquareSegment: LineLayerSegment {
    override var priority: Int {
        return 10
    }
    var cornerRadius:CGFloat = 30
    private func intermediatePoint(from: CGPoint, to: CGPoint) -> CGPoint? {
        let width = to.x - from.x
        let height = to.y - from.y
        if width != 0 && height != 0 {
            return self.segment.inverse ? CGPoint(
                x: from.x,
                y: to.y
            ) : CGPoint(
                x: to.x,
                y: from.y
            )
        }
        return nil
    }
    private var displayIntermediatePoint: CGPoint?
    override func draw(on path: UIBezierPath) {
        super.draw(on: path)
        let targetPoint = self.targetPoint
        let originPoint = path.currentPoint
        displayIntermediatePoint = nil
        if let intermediatePoint = self.intermediatePoint(from: originPoint, to: targetPoint) {
            self.displayIntermediatePoint = intermediatePoint
            let curveFrom = point(from: originPoint, to: intermediatePoint, apart: self.cornerRadius)
            let curveTo = point(from: targetPoint, to: intermediatePoint, apart: self.cornerRadius)
            path.addLine(to: curveFrom)
            path.addQuadCurve(to: curveTo, controlPoint: intermediatePoint)
        }
        path.addLine(to: targetPoint)
    }
    override func overlapRect(_ rect: CGRect) -> Bool {
        if let intermediatePoint = self.displayIntermediatePoint {
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
