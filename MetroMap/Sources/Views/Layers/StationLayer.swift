//
//  StationLayer.swift
//  MetroMap
//
//  Created by 张之行 on 3/21/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit
import SwiftSVG

class StationLayer: MetroMapLayer {
    var station: Station
    weak var mapView: MetroMapView!
    var observation: NSKeyValueObservation?
    var connectedLayers: Set<MetroMapLayer> = []

    init(_ station: Station, onMapView view: MetroMapView) {
        self.station = station
        self.mapView = view
        super.init()
        self.draw()
    }
    override init(layer: Any) {
        guard let stationLayer = layer as? StationLayer else {
            fatalError("Station Layer init(layer: Any) got unexpected layer")
        }
        self.station = stationLayer.station
        self.mapView = stationLayer.mapView
        self.observation = stationLayer.observation
        self.connectedLayers = stationLayer.connectedLayers
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var textLayer: CATextLayer?
    private var iconLayer: SVGLayer?
    override func draw(){
        self.textLayer?.removeFromSuperlayer()
        self.textLayer = nil
        self.iconLayer?.removeFromSuperlayer()
        self.iconLayer = nil

        guard let iconData = mapView.datasource?.stationIcons[station.level] else { return }
        self.position = self.station.position
        let textLayer = CATextLayer()
        textLayer.string = station.name
        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.alignmentMode = "center"
        self.textLayer = textLayer
        self.addSublayer(textLayer)
        CALayer(SVGData: iconData) { (theLayer) in
            let svglayer = theLayer.svgLayerCopy!
            svglayer.bounds = svglayer.boundingBox
            self.bounds.size = CGSize(width: svglayer.boundingBox.width*2, height: svglayer.boundingBox.height*2)
            svglayer.position.x = self.bounds.size.width / 2
            svglayer.position.y = self.bounds.size.height / 2
            
            textLayer.bounds.size.width = self.bounds.width
            textLayer.bounds.size.height = self.bounds.height / 4
            textLayer.fontSize = textLayer.bounds.size.height
            textLayer.frame.origin.x = 0
            textLayer.frame.origin.y = self.bounds.height
            self.iconLayer = svglayer
            self.addSublayer(svglayer)
        }
        if let delegate = self.mapView.delegate, delegate.metroMap(self.mapView, shouldEmphasizeElement: .station(self.station)) {
            self.backgroundColor = UIColor.red.cgColor
        }
        self.observation = station.observe(\.position) { station, change in
            for layer in self.connectedLayers {
                layer.draw()
            }
        }
    }
}
