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
    var mapView: MetroMapView
    
    init(_ segment: Segment, onMapView view: MetroMapView) {
        self.segment = segment
        self.mapView = view
        super.init()
        self.draw()
    }
    override init(layer: Any) {
        guard let layer = layer as? ConnectionLayer else {
            fatalError("Station Layer init(layer: Any) got unexpected layer")
        }
        self.segment = layer.segment
        self.mapView = layer.mapView
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
        let emphasize = mapView.delegate?.metroMap(mapView, shouldEmphasizeElement: .connection(segment)) ?? false
        self.strokeColor = emphasize ? UIColor.red.cgColor : UIColor.black.cgColor
        self.fillColor = UIColor.clear.cgColor
        self.lineWidth = 1
    }
}
