//
//  LineLayer.swift
//  TrainK
//
//  Created by 张之行 on 3/19/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

extension Segment.DrawingMode {
    var drawer: LineLayerSegment.Type {
        switch self {
        case .line:
            return LineLayerDirectSegment.self
        case .triangle:
            return LineLayerTriangleSegment.self
        case .square:
            return LineLayerSquareSegment.self
        case .curve:
            return LineLayerCurveSegment.self
        }
    }
}
class LineLayer: MetroMapLayer {
    var line: Line
    init(_ line: Line) {
        self.line = line
        super.init()
        self.draw()
    }
    override func draw(){
        let path = UIBezierPath()
        for segment in line.segments {
            let drawer = segment.drawingMode.drawer.init(segment)
            drawer.draw(on: path)
        }
        self.frame = self.bounds
        self.path = path.cgPath
        self.strokeColor = self.line.color.cgColor
        self.fillColor = UIColor.clear.cgColor
        self.lineWidth = 10
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
