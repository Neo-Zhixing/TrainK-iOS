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
        self.drawLines()
    }
    
    private func spacedPosition(_ position: CGPoint, spacing: CGFloat? = nil, offsetX: CGFloat = 0, offsetY: CGFloat = 0) -> CGPoint {
        let k = spacing ?? CGFloat(self.datasource.spacing)
        return CGPoint(
            x: position.x * k + offsetX,
            y: position.y * k + offsetY
        )
    }
    
    func drawStations() {
        let stationLayer = CALayer()
        for station in datasource.stations {
            let iconData = self.datasource.stationIcons[station.level]!
            CALayer(SVGData: iconData) { (svglayer) in
                let iconSize = svglayer.boundingBox.size
                svglayer.position = self.spacedPosition(station.position, offsetX: -iconSize.height/2, offsetY: -iconSize.width/2) // Offset the size of the icon
                stationLayer.addSublayer(svglayer)
            }
        }
        stationLayer.zPosition = 1
        self.layer.addSublayer(stationLayer)
    }
    
    func drawLines() {
        for line in datasource.lines {
            if line.segments.isEmpty { continue }

            let path = UIBezierPath()
            for segment in line.segments {
                if let fromNode = segment.from {
                    path.move(to: self.spacedPosition(fromNode.position))
                }
                let targetPoint = self.spacedPosition(segment.to.position)
                let width = abs(targetPoint.x - path.currentPoint.x)
                let height = abs(targetPoint.y - path.currentPoint.y)
                if (width != height) {
                    let intermediatePoint:CGPoint
                    print(segment.inverse)
                    if width > height {
                        intermediatePoint = CGPoint(
                            x: targetPoint.x - height,
                            y: path.currentPoint.y
                        )
                    } else {
                        intermediatePoint = CGPoint(
                            x: path.currentPoint.x,
                            y: targetPoint.y - width
                        )
                    }
                    path.addLine(to: intermediatePoint)
                }
                path.addLine(to: targetPoint)
            }

            let layer = CAShapeLayer()
            layer.frame = self.bounds
            layer.path = path.cgPath
            layer.strokeColor = UIColor.blue.cgColor
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = 10
            self.layer.addSublayer(layer)
        }
    }
}
