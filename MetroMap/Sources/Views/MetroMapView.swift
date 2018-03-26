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
    func metroMap(_ metroMap: MetroMapView, canSelectElement element: MetroMapView.Element) -> Bool
    func metroMap(_ metroMap: MetroMapView, willSelectElement element: MetroMapView.Element, onFrame frame: CGRect)
    func metroMap(_ metroMap: MetroMapView, didSelectElement element: MetroMapView.Element, onFrame frame: CGRect)
    func metroMap(_ metroMap: MetroMapView, moveElement element: MetroMapView.Element, to point: CGPoint, withTouch touch: UITouch)
    func metroMap(_ metroMap: MetroMapView, willDeselectElement element: MetroMapView.Element)
    func metroMap(_ metroMap: MetroMapView, didDeselectElement element: MetroMapView.Element)

    func metroMap(_ metroMap: MetroMapView, shouldEmphasizeElement element: MetroMapView.Element) -> Bool
}

public extension MetroMapViewDelegate {
    func metroMap(_ metroMap: MetroMapView, canSelectElement element: MetroMapView.Element) -> Bool {return false}
    func metroMap(_ metroMap: MetroMapView, willSelectElement element: MetroMapView.Element, onFrame frame: CGRect) {}
    func metroMap(_ metroMap: MetroMapView, didSelectElement element: MetroMapView.Element, onFrame frame: CGRect) {}
    func metroMap(_ metroMap: MetroMapView, moveElement element: MetroMapView.Element, to point: CGPoint, withTouch touch: UITouch) {}
    func metroMap(_ metroMap: MetroMapView, willDeselectElement element: MetroMapView.Element) {}
    func metroMap(_ metroMap: MetroMapView, didDeselectElement element: MetroMapView.Element) {}
    
    func metroMap(_ metroMap: MetroMapView, shouldEmphasizeElement element: MetroMapView.Element) -> Bool {
        return false
    }
}

class MetroMapLayer: CAShapeLayer {
    func draw() {}
    func select() {}
    func deselect() {}
    var element:MetroMapView.Element? {
        return nil
    }
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
    public enum Element: Equatable {
        case station(Station)
        case connection(Segment)
        case segment(Segment)
        public static func ==(lhs: Element, rhs: Element) -> Bool {
            switch (lhs, rhs) {
            case (let .station(a1), let .station(a2)):
                return a1 == a2
            case (let .connection(a1), let .connection(a2)):
                return a1 == a2
            case (let .segment(a1), let .segment(a2)):
                return a1 == a2
            default:
                return false
            }
        }
    }
    
    var selected: Element?
    var selectedLayer: MetroMapLayer?
    private var currentTouch: UITouch?
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches {
            let location = touch.location(in: self)
            var testingLayer: CALayer? = self.stationLayer.presentation()?.hitTest(location)?.model()
            // Tracing back to find out what's the station layer hitted
            for _ in 0..<5 {
                if let _ = testingLayer as? MetroMapLayer {
                    break
                }
                testingLayer = testingLayer?.superlayer
            }
            if let layer = testingLayer as? MetroMapLayer,
                let element = layer.element,
                layer.element != selected,
                self.delegate?.metroMap(self, canSelectElement: element) ?? false {
                self.delectedAll()
                self.selectedLayer = layer
                self.selected = element
                self.currentTouch = touch
                layer.select()
                self.delegate?.metroMap(self, willSelectElement: element, onFrame: layer.frame)
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
                self.delegate?.metroMap(self, didSelectElement: selection, onFrame: layer.frame)
            }
        }
    }
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        for touch in touches {
            if touch == self.currentTouch, let selection = self.selected {
                self.delegate?.metroMap(self,
                                        moveElement: selection,
                                        to: touch.location(in: self),
                                        withTouch: touch)
            }
        }
    }
    open func delectedAll(){
        guard let selection = self.selected else {return}
        self.delegate?.metroMap(self, willDeselectElement: selection)
        self.selected = nil
        self.selectedLayer?.deselect()
        self.selectedLayer = nil
    }
    // MARK: - Scaling
    var contentScale: CGFloat = 1
    func setScale(_ scale: CGFloat) {
        self.contentScale = 1
        if let stationLayers = self.stationLayer.sublayers as? [StationLayer] {
            for layer in stationLayers {
                layer.setScale(scale)
            }
        }
        
    }
}

