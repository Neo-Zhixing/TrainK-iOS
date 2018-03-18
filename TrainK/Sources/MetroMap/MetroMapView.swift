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
    }
    
    func drawStations() {
        print("Okay we're here")

        for station in datasource.stations {
            print("adding stations")
            let iconData = self.datasource.stationIcons[station.level]!
            CALayer(SVGData: iconData) { (svglayer) in
                let spacing = CGFloat(self.datasource.spacing)
                svglayer.position = CGPoint(
                    x: station.position.x * spacing,
                    y: station.position.y * spacing
                )
                self.layer.addSublayer(svglayer)
            }
        }
    }

}
