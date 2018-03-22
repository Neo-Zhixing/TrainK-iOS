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
    var addButton: UIBarButtonItem?
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setupToolbarItems()
    }
    open func setupToolbarItems() {
        self.toolbarItems = []
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addStation))
        self.addButton = addButton
        self.toolbarItems?.append(addButton)
        self.navigationController?.isToolbarHidden = false
    }
    
    @IBAction open func addStation(sender: UIBarButtonItem?) {
        guard let map = self.metroMap, let scrollView = self.scrollView else {return}
        var maxID = Int.min
        for node in map.nodes.union(map.stations as Set<Node>) { if node.id > maxID { maxID = node.id } }
        let station = Station(id: maxID + 1)
        station.name = "Untitled"
        // Move the station to the center
        let position = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height/2)
        station.position = self.metroMapView.convert(position, from: self.view) + scrollView.contentOffset
        self.metroMapView.addStation(station)
    }
}
