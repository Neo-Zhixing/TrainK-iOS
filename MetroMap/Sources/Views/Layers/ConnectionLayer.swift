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
    
    init(_ segment: Segment, onMapView view: MetroMapView) {
        self.segment = segment
        super.init()
        self.mapView = view
    }
    override init(layer: Any) {
        guard let layer = layer as? ConnectionLayer else {
            fatalError("Station Layer init(layer: Any) got unexpected layer")
        }
        self.segment = layer.segment
        super.init(layer: layer)
        self.mapView = layer.mapView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(){
        let path = UIBezierPath()
        let drawer = segment.drawingMode.drawer.init(segment, onLayer: self)
        drawer.draw(on: path)
        self.path = path.cgPath
        //self.frame = self.bounds
        let emphasize = mapView.delegate?.metroMap(mapView, shouldEmphasizeElement: .connection(segment)) ?? false
        self.strokeColor = emphasize ? UIColor.red.cgColor : UIColor.black.cgColor
        self.fillColor = UIColor.clear.cgColor
        self.lineWidth = 1
    }
}
