//
//  LineLayerSegment.swift
//  TrainK
//
//  Created by 张之行 on 3/19/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

class LineLayerSegment {
    var segment: Line.Segment
    weak var lineLayer: LineLayer!
    
    required init(_ segment: Line.Segment, onLayer layer: LineLayer) {
        self.segment = segment
        self.lineLayer = layer
    }

    func draw(on path: UIBezierPath) {
    }
}
