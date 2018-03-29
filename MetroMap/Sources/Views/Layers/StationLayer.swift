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
    override var element: MetroMapView.Element {
        return .station(self.station)
    }
    var observation: NSKeyValueObservation?
    var connectedLayers: Set<MetroMapLayer> = []
    var connectedSegmentDrawer: Set<LineLayerSegment> = []

    init(_ station: Station, onMapView view: MetroMapView) {
        self.station = station
        super.init()
        self.mapView = view
    }
    override init(layer: Any) {
        guard let stationLayer = layer as? StationLayer else {
            fatalError("Station Layer init(layer: Any) got unexpected layer")
        }
        self.station = stationLayer.station
        self.observation = stationLayer.observation
        self.connectedLayers = stationLayer.connectedLayers
        super.init(layer: layer)
        self.mapView = stationLayer.mapView
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
        
        let iconData: Data
        if let oriData = mapView.datasource?.stationIcons[station.level] {
            iconData = oriData
        } else {
            guard let oriData = NSDataAsset(name: station.level.rawValue, bundle: Bundle(for: StationLayer.self))?.data else {return}
            iconData = oriData
            mapView.datasource?.stationIcons[station.level] = oriData
        }
        
        
        self.position = self.station.position
        let textLayer = CATextLayer()
        textLayer.string = station.name
        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.backgroundColor = mapView.datasource?.configs.backgroundColor.cgColor
        let fontSize = self.station.level.fontSize
        let font = UIFont.systemFont(ofSize: fontSize)
        if let size = self.station.name?.size(withAttributes: [NSAttributedStringKey.font: font]) {
            textLayer.bounds.size = size
        }
        textLayer.font = font
        textLayer.fontSize = fontSize
        if let maxScale = self.mapView.datasource?.configs.maxZoom {
            textLayer.contentsScale = UIScreen.main.scale * maxScale
        }
        self.textLayer = textLayer
        self.addSublayer(textLayer)
        
        CALayer(SVGData: iconData) { (theLayer) in
            let svglayer = theLayer.svgLayerCopy!
            if let size = svglayer.sublayers?.first?.frame.size {
                svglayer.bounds.size = size
            }
            self.bounds.size = CGSize(width: svglayer.bounds.size.width*2, height: svglayer.bounds.size.height*2)
            svglayer.position.x = self.bounds.size.width / 2
            svglayer.position.y = self.bounds.size.height / 2
            
            self.iconLayer = svglayer
            self.addSublayer(svglayer)
            self.layoutLabel()
            self.adjustOrientation()
        }
        if let delegate = self.mapView.delegate, delegate.metroMap(self.mapView, shouldEmphasizeElement: .station(self.station)) {
            self.backgroundColor = UIColor.red.cgColor
        }
        self.observation = station.observe(\.position) { station, change in
            for layer in self.connectedLayers {
                layer.draw()
            }
            for layer in self.mapView.stationLayer.sublayers as! [StationLayer] {
                layer.adjustOrientation()
                layer.layoutLabel()
            }
        }
    }
    override func select() {
        self.transform = CATransform3DMakeScale(2, 2, 1)
    }
    override func deselect() {
        self.transform = CATransform3DMakeScale(1, 1, 1)
    }
    
    enum LabelPosition {
        case top, bottom, left, right, upright, upleft, downright, downleft, center
        static let all:[LabelPosition] = [.top, .bottom, .left, .right, .upright, .upleft, .downright, .downleft, .center]
        func position(frame: CGRect, targetSize size: CGSize) -> CGPoint {
            let horizontalCenter = frame.width/2 + frame.minX
            let verticleCenter = frame.minY + frame.height/2
            let up = frame.minY - size.height/2
            let down = frame.maxY + size.height/2
            let left = frame.minX - size.width/2
            let right = frame.maxX + size.width/2
            switch self {
            case .top:
                return CGPoint(x: horizontalCenter, y: up)
            case .bottom:
                return CGPoint(x: horizontalCenter, y: down)
            case .left:
                return CGPoint(x: left, y: verticleCenter)
            case .right:
                return CGPoint(x: right, y: verticleCenter)
            case .downleft:
                return CGPoint(x: left, y: down)
            case .downright:
                return CGPoint(x: right, y: down)
            case .upleft:
                return CGPoint(x: left, y: up)
            case .upright:
                return CGPoint(x: right, y: up)
            case .center:
                return CGPoint(x: horizontalCenter, y: verticleCenter)
            }
        }
    }
    func setScale(_ scale: CGFloat) {
        if scale < station.level.displayLabelThresholdScale {
            textLayer?.isHidden = true
        } else {
            textLayer?.isHidden = false
        }
        if scale < station.level.displayIconThresholdScale {
            iconLayer?.isHidden = true
        } else {
            iconLayer?.isHidden = false
        }
    }
    func layoutLabel() {
        guard let textLayer = self.textLayer,
            let lineLayers = self.mapView.lineLayer.sublayers as? [LineLayer] else {
            return
        }
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.2)
        CATransaction.setDisableActions(false)
        labelPositionLoop: for position in LabelPosition.all {
            textLayer.position = position.position(frame: self.bounds, targetSize: textLayer.bounds.size)
            for lineLayer in lineLayers {
                if lineLayer.overlapRect(convert(textLayer.frame, to: self.mapView.layer)) {
                    continue labelPositionLoop
                }
            }
            break
        }
        CATransaction.commit()
    }
    func adjustOrientation() {
        var orientation = CGFloat()
        if self.connectedSegmentDrawer.count == 2,
        let segment1 = Array(connectedSegmentDrawer)[0].endpointOrientation(for: station),
        let segment2 = Array(connectedSegmentDrawer)[1].endpointOrientation(for: station) {
            var angle = segment1 - segment2
            if angle > CGFloat.pi*2 { angle -= CGFloat.pi*2 }
            if angle < 0 { angle += CGFloat.pi*2 }
            if angle == CGFloat.pi {
                orientation = segment1 > segment2 ? segment1 : segment2
            }
            else {
                orientation = angle < CGFloat.pi ? segment1 : segment2
            }
        }
        iconLayer?.setAffineTransform(CGAffineTransform(rotationAngle: orientation))
    }
}


private extension Station.Level {
    var displayLabelThresholdScale: CGFloat {
        switch self {
        case .minor: return 1
        case .major: return 0.7
        case .interchange: return 0.4
        case .intercity: return 0.2
        }
    }
    var displayIconThresholdScale: CGFloat {
        switch self {
        case .minor: return 0.5
        case .major: return 0.3
        case .interchange: return 0.1
        case .intercity: return 0
        }
    }
    var fontSize: CGFloat {
        switch self {
        case .minor: return 13
        case .major: return 15
        case .interchange: return 17
        case .intercity: return 20
        }
    }
}
