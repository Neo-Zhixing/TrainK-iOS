//
//  MetroMapEditingViewController.swift
//  MetroMap
//
//  Created by 张之行 on 3/21/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

open class MetroMapEditingViewController: MetroMapScrollableViewController {
    var gridSize: CGFloat = 25
    override open func metroMap(_ metroMap: MetroMapView, willSelectStation station: Station, onFrame frame: CGRect) {
        self.scrollView?.isScrollEnabled = false
    }
    override open func metroMap(_ metroMap: MetroMapView, didSelectStation station: Station, onFrame frame: CGRect) {
        self.scrollView?.isScrollEnabled = true
    }
    override open func metroMap(_ metroMap: MetroMapView, moveStation station: Station, to point: CGPoint, withTouch touch: UITouch) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let newPosition = snapToGrid(point)
        metroMap.selectedLayer?.position = newPosition
        station.position = newPosition
        CATransaction.commit()
    }
    private func snapToGrid(_ point: CGPoint) -> CGPoint{
        if gridSize == 0 {return point}
        return CGPoint(
            x: (point.x / gridSize).rounded() * gridSize,
            y: (point.y / gridSize).rounded() * gridSize
        
        )
    }
    override open func metroMap(_ metroMap: MetroMapView, canSelectStation station: Station) -> Bool {
        return true
    }
}
