//
//  MetroMapView.swift
//  TrainK
//
//  Created by 张之行 on 3/19/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit
import SwiftSVG

public protocol MetroMapViewDelegate:NSObjectProtocol {
    
}
public class MetroMapView: UIView {
    public weak var datasource:MetroMap! {
        didSet {
            self.reload()
        }
    }
    public weak var delegate: MetroMapViewDelegate?

    public func reload() {
        if self.datasource == nil { return }
        self.drawStations()
        self.drawConnections()
        for line in datasource.lines {
            let layer = LineLayer(line)
            self.layer.addSublayer(layer)
        }
    }
    private func drawStations() {
        let stationLayer = CALayer()
        for station in datasource.stations {
            let iconData = self.datasource.stationIcons[station.level]!
            CALayer(SVGData: iconData) { (svglayer) in
                let iconSize = svglayer.boundingBox.size
                svglayer.position = CGPoint(
                    x: station.position.x - iconSize.height / 2,
                    y: station.position.y - iconSize.width / 2
                )
                stationLayer.addSublayer(svglayer)
            }
        }
        stationLayer.zPosition = 1
        self.layer.addSublayer(stationLayer)
    }
    private func drawConnections() {
        let layer = CALayer()
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
            layer.addSublayer(conlayer)
        }
        self.layer.addSublayer(layer)
    }
}
