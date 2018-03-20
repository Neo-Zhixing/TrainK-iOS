//
//  MetroMapView.swift
//  TrainK
//
//  Created by 张之行 on 3/19/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit
import SwiftSVG

public protocol MetroMapViewDelegate: NSObjectProtocol {
    func metroMap(_ metroMap: MetroMapView, canSelectStation station: Station) -> Bool
    func metroMap(_ metroMap: MetroMapView, selectStation station: Station, onFrame frame: CGRect)
    func metroMap(_ metroMap: MetroMapView, deselectStation station: Station)
}

public extension MetroMapViewDelegate {
    public func metroMap(_ metroMap: MetroMapView, canSelectStation station: Station) -> Bool {
        return true
    }
    
    public func metroMap(_ metroMap: MetroMapView, selectStation station: Station, atPosition position: CGPoint) {
    }
    public func metroMap(_ metroMap: MetroMapView, deselectStation station: Station){}
}

open class MetroMapView: UIView {
    open weak var datasource:MetroMap! {
        didSet {
            self.reload()
        }
    }
    open weak var delegate: MetroMapViewDelegate?

    
    private var lineLayer = CALayer()
    private var stationLayer = CALayer()
    private var connectionLayer = CALayer()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    private func setup() {
        stationLayer.zPosition = 3
        self.layer.addSublayer(lineLayer)
        self.layer.addSublayer(stationLayer)
        self.layer.addSublayer(connectionLayer)
        self.backgroundColor = UIColor.clear
    }
    open func reload() {
        if self.datasource == nil { return }
        self.drawStations()
        self.drawConnections()
        for line in datasource.lines {
            let layer = LineLayer(line)
            self.lineLayer.addSublayer(layer)
        }
        self.frame.size = self.datasource.configs.size
    }
    open var stationLayerData: [CALayer:Station] = [:]
    private func drawStations() {
        for station in datasource.stations {
            let iconData = self.datasource.stationIcons[station.level]!
            CALayer(SVGData: iconData) { (svglayer) in
                svglayer.position = CGPoint(
                    x: station.position.x,
                    y: station.position.y
                )
                svglayer.bounds = svglayer.boundingBox
                self.stationLayer.addSublayer(svglayer)
                self.stationLayerData[svglayer] = station
            }
        }
    }
    private func drawConnections() {
        for con in datasource.connections {
            let conlayer = CAShapeLayer()
            let path = UIBezierPath()
            let drawer = con.drawingMode.drawer.init(con)
            drawer.draw(on: path)
            conlayer.path = path.cgPath
            //self.frame = self.bounds
            conlayer.strokeColor = UIColor.black.cgColor
            conlayer.fillColor = UIColor.clear.cgColor
            conlayer.lineWidth = 1
            self.connectionLayer.addSublayer(conlayer)
        }
    }
    
    enum Selection {
        case station(Station)
    }
    
    var selected: Selection?
    var selectedLayer: CALayer?
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches {
            let location = touch.location(in: self)
            if let stationLayer = self.stationLayer.presentation()?.hitTest(location),
                let svglayer = stationLayer.model().superlayer as? SVGLayer,
                svglayer != self.selectedLayer,
                let station = self.stationLayerData[svglayer],
                self.delegate?.metroMap(self, canSelectStation: station) ?? true {
                // Select the station and start the animation
                self.delectedAll()
                self.selectedLayer = svglayer
                svglayer.transform = CATransform3DMakeScale(2, 2, 1)
                self.selected = .station(station)
                self.delegate?.metroMap(self, selectStation: station, onFrame: svglayer.frame)
            } else {
                self.delectedAll()
            }
        }
    }
    open func delectedAll(){
        guard let selection = self.selected else {return}
        switch selection {
        case .station(let station):
            self.delegate?.metroMap(self, deselectStation: station)
        }
        self.selected = nil
        self.selectedLayer?.transform = CATransform3DMakeScale(1, 1, 1)
        self.selectedLayer = nil
    }
}
