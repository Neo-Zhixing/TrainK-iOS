//
//  LineLayer.swift
//  TrainK
//
//  Created by 张之行 on 3/19/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

private extension Line.Segment.DrawingMode {
    var drawer: LineLayerSegment.Type {
        switch self {
        default:
            return LineLayerTriangleSegment.self
        }
    }
}
class LineLayer: CAShapeLayer {
    var line: Line
    var mapView: MetroMapView
    init(_ line: Line, mapView: MetroMapView) {
        self.line = line
        self.mapView = mapView
        super.init()
        let path = UIBezierPath()
        for segment in line.segments {
            let drawer = segment.drawingMode.drawer.init(segment, onLayer: self)
            drawer.draw(on: path)
        }
        self.frame = self.bounds
        self.path = path.cgPath
        self.strokeColor = UIColor.blue.cgColor
        self.fillColor = UIColor.clear.cgColor
        self.lineWidth = 10
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
