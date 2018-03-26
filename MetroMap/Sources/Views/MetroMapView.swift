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
    func metroMap(_ metroMap: MetroMapView, moveStation station: Station, to point: CGPoint, withTouch touch: UITouch)
    func metroMap(_ metroMap: MetroMapView, willDeselectStation station: Station)
    func metroMap(_ metroMap: MetroMapView, didDeselectStation station: Station)

    func metroMap(_ metroMap: MetroMapView, shouldEmphasizeElement element: MetroMapView.Element) -> Bool
}

public extension MetroMapViewDelegate {
    public func metroMap(_ metroMap: MetroMapView, canSelectStation station: Station) -> Bool {
        return false
    }
    public func metroMap(_ metroMap: MetroMapView, willSelectStation station: Station, onFrame frame: CGRect) {}
    public func metroMap(_ metroMap: MetroMapView, didSelectStation station: Station, onFrame frame: CGRect) {}
    public func metroMap(_ metroMap: MetroMapView, willDeselectStation station: Station) {}
    public func metroMap(_ metroMap: MetroMapView, didDeselectStation station: Station) {}
    public func metroMap(_ metroMap: MetroMapView, moveStation station: Station, to point: CGPoint, withTouch touch: UITouch) {}
    public func metroMap(_ metroMap: MetroMapView, shouldEmphasizeElement element: MetroMapView.Element) -> Bool {
        return false
    }
}

class MetroMapLayer: CAShapeLayer {
    func draw() {}
}
open class MetroMapView: UIView {
    open weak var datasource:MetroMap?
    open weak var delegate: MetroMapViewDelegate?

    
    private var lineLayer = CALayer()
    private var stationLayer = CALayer()
    private var connectionLayer = CALayer()
    private var backgroundLayer = CALayer()
    
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
        backgroundLayer.zPosition = -1
        self.layer.addSublayer(lineLayer)
        self.layer.addSublayer(stationLayer)
        self.layer.addSublayer(connectionLayer)
        self.layer.addSublayer(backgroundLayer)
        self.backgroundColor = UIColor.clear
    }
    // MARK: - View Rendering
    private var stationMapping: [Node: StationLayer] = [:]

    private func renderStation(_ station: Station) {
        let layer = StationLayer(station, onMapView: self)
        self.stationLayer.addSublayer(layer)
        stationMapping[station] = layer
    }
    private func renderConnection(_ connection: Segment) {
        let layer = ConnectionLayer(connection, onMapView: self)
        self.connectionLayer.addSublayer(layer)
        stationMapping[connection.to]?.connectedLayers.insert(layer)
        stationMapping[connection.from]?.connectedLayers.insert(layer)
    }
    private func renderLine(_ line: Line) {
        let layer = LineLayer(line, onMapView: self)
        self.lineLayer.addSublayer(layer)
        // Adding connectedLayers to our station layers
        for seg in line.segments {
            stationMapping[seg.to]?.connectedLayers.insert(layer)
            stationMapping[seg.from]?.connectedLayers.insert(layer)
        }
    }
    private func renderBackground(_ background: Background) {
        CALayer(SVGURL: background.imageURL) {
            svglayer in
            svglayer.position = background.position
            self.backgroundLayer.addSublayer(svglayer)
        }
    }
    // MARK: - Data Management and Runtime Alternation
    open func reload() {
        self.stationMapping = [:]
        self.stationLayer.sublayers = nil
        self.lineLayer.sublayers = nil
        self.connectionLayer.sublayers = nil
        self.backgroundLayer.sublayers = nil
        guard let map = self.datasource else {
            print("MetroMap Doesn't have a datasource")
            return
        }
        for station in map.stations {
            renderStation(station)
        }
        for connection in map.connections {
            renderConnection(connection)
        }
        for line in map.lines {
            renderLine(line)
        }
        for background in map.backgrounds {
            renderBackground(background)
        }
        self.frame.size = map.configs.size
        self.backgroundColor = map.configs.backgroundColor
    }
    open func addStation(_ station: Station) {
        self.datasource?.addStation(station)
        self.renderStation(station)
    }
    
    // MARK: - Touch Event Handling
    public enum Element {
        case station(Station)
        case connection(Segment)
        case segment(Segment)
    }
    
    var selected: Element?
    var selectedLayer: MetroMapLayer?
    private var currentTouch: UITouch?
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches {
            let location = touch.location(in: self)
            var stationLayer: CALayer? = self.stationLayer.presentation()?.hitTest(location)?.model()
            // Tracing back to find out what's the station layer hitted
            for _ in 0..<3 {
                if let _ = stationLayer as? StationLayer {
                    break
                }
                stationLayer = stationLayer?.superlayer
            }
            if let layer = stationLayer as? StationLayer,
                self.delegate?.metroMap(self, canSelectStation: layer.station) ?? false {
                // Select the station and start the animation
                self.delectedAll()
                self.selectedLayer = layer
                layer.transform = CATransform3DMakeScale(2, 2, 1)
                self.selected = .station(layer.station)
                self.currentTouch = touch
                self.delegate?.metroMap(self, willSelectStation: layer.station, onFrame: layer.frame)
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
                default:
                    fatalError("Not Implemented Yet")
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
                    self.delegate?.metroMap(self,
                                            moveStation: station,
                                            to: touch.location(in: self),
                                            withTouch: touch)
                default:
                    fatalError("Not Implemented Yet")
                }
            }
        }
    }
    open func delectedAll(){
        guard let selection = self.selected else {return}
        switch selection {
        case .station(let station):
            self.delegate?.metroMap(self, willDeselectStation: station)
        default:
            fatalError("Not Implemented Yet")
        }
        self.selected = nil
        self.selectedLayer?.transform = CATransform3DMakeScale(1, 1, 1)
        self.selectedLayer = nil
    }
}
