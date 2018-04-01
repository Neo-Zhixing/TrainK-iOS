//
//  LineLayerSegment.swift
//  TrainK
//
//  Created by 张之行 on 3/19/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

class LineLayerSegment {
    var priority: Int {
        return 0
    }
    var segment: Segment
    weak var layer: MetroMapLayer!
    func offset(for node: Node) -> CGPoint {
        var offset = CGPoint()
        guard let stationLayer = self.layer.mapView.stationMapping[node],
            let myOrientation = self.endpointOrientation(for: node)
        else {
            return offset
        }
        for drawer in stationLayer.connectedSegmentDrawer where drawer.layer != self.layer {
            if let orientation = drawer.endpointOrientation(for: node),
                orientation == myOrientation {
                // Parallel
                
                if self.priority > drawer.priority {
                    offset = offset + CGPoint(x: sin(-myOrientation)*10, y: cos(-myOrientation)*10)
                }
                else if self.priority == drawer.priority,
                    let myLine = self.segment.line,
                    let theLine = drawer.segment.line,
                    myLine.id > theLine.id{
                    offset = offset + CGPoint(x: sin(-myOrientation)*10, y: cos(-myOrientation)*10)
                }
            }
        }
        return offset
    }
    var targetPoint: CGPoint {
        return segment.to.position + offset(for: segment.to)
    }
    var originPoint: CGPoint {
        return segment.from.position + offset(for: segment.from) * -1
    }
    
    required init(_ segment: Segment, onLayer layer: MetroMapLayer) {
        self.segment = segment
        self.layer = layer
    }

    func draw(on path: UIBezierPath) {
        path.move(to: self.originPoint)
    }
    func overlapRect(_ rect: CGRect) -> Bool {
        return false
    }
    func endpointOrientation(for node: Node) -> CGFloat? {
        if node == segment.from {
            return angle(from: node.position, to: segment.to.position)
        } else if node == segment.to {
            return angle(from: node.position, to: segment.from.position)
        }
        return nil
    }
}

extension LineLayerSegment: Hashable {
    static func ==(lhs: LineLayerSegment, rhs: LineLayerSegment) -> Bool {
        return lhs.segment == rhs.segment
    }
    
    var hashValue: Int {
        return segment.hashValue
    }
}

class LineLayerDirectSegment:LineLayerSegment {
    override var priority: Int {
        return 1
    }
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
    var intermediatePoint: CGPoint?
    override func draw(on path: UIBezierPath) {
        super.draw(on: path)
        let intermediatePoint = self.segment.inverse ? CGPoint(
            x: path.currentPoint.x,
            y: targetPoint.y
        ) : CGPoint(
            x: targetPoint.x,
            y: path.currentPoint.y
        )
        self.intermediatePoint = intermediatePoint
        path.addQuadCurve(to: targetPoint, controlPoint: intermediatePoint)
    }
    override func endpointOrientation(for node: Node) -> CGFloat? {
        guard let intermediatePoint = self.intermediatePoint else {
            return super.endpointOrientation(for: node)
        }
        return angle(from: node.position, to: intermediatePoint)
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

internal func angle(from: CGPoint, to: CGPoint) -> CGFloat {
    let height = to.y - from.y
    let width = to.x - from.x
    if width == 0 {
        return height > 0 ? CGFloat.pi*0.5 : CGFloat.pi*1.5
    }
    let slope = height / width
    var result = atan(slope)
    if width < 0 {
        result += CGFloat.pi
    }
    if (result < 0) { result += 2 * CGFloat.pi }
    return  result
}
