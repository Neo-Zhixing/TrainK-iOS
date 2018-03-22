//
//  ConnectionLayer.swift
//  MetroMap
//
//  Created by 张之行 on 3/22/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

class ConnectionLayer: MetroMapLayer {
    var segment: Segment
    
    init(_ segment: Segment) {
        self.segment = segment
        super.init()
        self.draw()
    }
    override init(layer: Any) {
        guard let layer = layer as? ConnectionLayer else {
            fatalError("Station Layer init(layer: Any) got unexpected layer")
        }
        self.segment = layer.segment
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(){
        let path = UIBezierPath()
        let drawer = segment.drawingMode.drawer.init(segment)
        drawer.draw(on: path)
        self.path = path.cgPath
        //self.frame = self.bounds
        self.strokeColor = UIColor.black.cgColor
        self.fillColor = UIColor.clear.cgColor
        self.lineWidth = 1
    }
}
