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
    override func draw(on path: UIBezierPath) {
        super.draw(on: path)
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
            let curveFrom = point(from: path.currentPoint, to: intermediatePoint, apart: self.cornerRadius)
            let curveTo = point(from: targetPoint, to: intermediatePoint, apart: self.cornerRadius)
            path.addLine(to: curveFrom)
            path.addQuadCurve(to: curveTo, controlPoint: intermediatePoint)
        }
        path.addLine(to: targetPoint)
    }
}
