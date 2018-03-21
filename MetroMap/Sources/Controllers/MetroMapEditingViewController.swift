//
//  MetroMapEditingViewController.swift
//  MetroMap
//
//  Created by 张之行 on 3/21/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

open class MetroMapEditingViewController: MetroMapScrollableViewController {
    override open func metroMap(_ metroMap: MetroMapView, willSelectStation station: Station, onFrame frame: CGRect) {
        self.scrollView?.isScrollEnabled = false
    }
    override open func metroMap(_ metroMap: MetroMapView, didSelectStation station: Station, onFrame frame: CGRect) {
        self.scrollView?.isScrollEnabled = true
    }
    override open func metroMap(_ metroMap: MetroMapView, moveStation station: Station, to point: CGPoint) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        metroMap.selectedLayer?.position = point
        station.position = point
        CATransaction.commit()
        
    }
    override open func metroMap(_ metroMap: MetroMapView, canSelectStation station: Station) -> Bool {
        return true
    }
}
