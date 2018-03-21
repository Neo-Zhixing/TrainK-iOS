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
    func metroMap(_ metroMap: MetroMapView, willSelectStation station: Station, onFrame frame: CGRect)
    func metroMap(_ metroMap: MetroMapView, didSelectStation station: Station, onFrame frame: CGRect)
    func metroMap(_ metroMap: MetroMapView, moveStation station: Station, to point: CGPoint)
    func metroMap(_ metroMap: MetroMapView, willDeselectStation station: Station)
    func metroMap(_ metroMap: MetroMapView, didDeselectStation station: Station)
}

public extension MetroMapViewDelegate {
    public func metroMap(_ metroMap: MetroMapView, canSelectStation station: Station) -> Bool {
        return false
    }
    public func metroMap(_ metroMap: MetroMapView, willSelectStation station: Station, onFrame frame: CGRect) {}
    public func metroMap(_ metroMap: MetroMapView, didSelectStation station: Station, onFrame frame: CGRect) {}
    public func metroMap(_ metroMap: MetroMapView, willDeselectStation station: Station) {}
    public func metroMap(_ metroMap: MetroMapView, didDeselectStation station: Station) {}
    public func metroMap(_ metroMap: MetroMapView, moveStation station: Station, to point: CGPoint) {}
}

open class MetroMapView: UIView {
    open weak var datasource:MetroMap?
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
        guard let map = self.datasource else { return }
        self.drawStations()
        self.drawConnections()
        for line in map.lines {
            let layer = LineLayer(line)
            self.lineLayer.addSublayer(layer)
        }
        self.frame.size = map.configs.size
    }
    open var stationLayerData: [CALayer:Station] = [:]
    private func drawStations() {
        guard let map = self.datasource else { return }
        for station in map.stations {
            let iconData = map.stationIcons[station.level]!
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
        guard let map = self.datasource else { return }
        for con in map.connections {
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
    private var currentTouch: UITouch?
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches {
            let location = touch.location(in: self)
            if let stationLayer = self.stationLayer.presentation()?.hitTest(location),
                let svglayer = stationLayer.model().superlayer as? SVGLayer,
                let station = self.stationLayerData[svglayer],
                self.delegate?.metroMap(self, canSelectStation: station) ?? false {
                // Select the station and start the animation
                self.delectedAll()
                self.selectedLayer = svglayer
                svglayer.transform = CATransform3DMakeScale(2, 2, 1)
                self.selected = .station(station)
                self.currentTouch = touch
                self.delegate?.metroMap(self, willSelectStation: station, onFrame: svglayer.frame)
            } else {
                self.delectedAll()
            }
        }
    }
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            if touch == self.currentTouch, let layer = self.selectedLayer, let selection = self.selected {
                self.currentTouch = nil
                switch selection {
                case .station(let station):
                    self.delegate?.metroMap(self, didSelectStation: station, onFrame: layer.frame)
                }
            }
        }
    }
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        for touch in touches {
            if touch == self.currentTouch, let selection = self.selected {
                switch selection {
                case .station(let station):
                    self.delegate?.metroMap(self, moveStation: station, to: touch.location(in: self))
                }
            }
        }
    }
    open func delectedAll(){
        guard let selection = self.selected else {return}
        switch selection {
        case .station(let station):
            self.delegate?.metroMap(self, willDeselectStation: station)
        }
        self.selected = nil
        self.selectedLayer?.transform = CATransform3DMakeScale(1, 1, 1)
        self.selectedLayer = nil
    }
}
