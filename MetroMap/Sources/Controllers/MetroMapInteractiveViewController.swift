//
//  MetroMapInteractiveViewController.swift
//  MetroMap
//
//  Created by 张之行 on 3/21/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

open class MetroMapInteractiveViewController: MetroMapScrollableViewController {
    open var popoverViewController:StationPopoverViewController?
    
    override open func metroMap(_ metroMap: MetroMapView, willSelectStation station: Station, onFrame frame: CGRect) {
        let popoverViewController = StationPopoverViewController(station)
        popoverViewController.mapViewController = self
        popoverViewController.modalPresentationStyle = .popover
        popoverViewController.popoverPresentationController?.sourceView = self.metroMapView
        popoverViewController.popoverPresentationController?.sourceRect = frame
        popoverViewController.popoverPresentationController?.passthroughViews = [self.metroMapView]
        self.popoverViewController = popoverViewController
        self.present(popoverViewController, animated: true, completion: nil)


    }
    override open func metroMap(_ metroMap: MetroMapView, willDeselectStation station: Station) {
        self.popoverViewController?.dismiss(animated: false, completion: nil)
        self.popoverViewController = nil
    }
    override open func metroMap(_ metroMap: MetroMapView, canSelectStation station: Station) -> Bool {
        return true
    }
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.metroMapView.delectedAll()
    }
    
    // MARK: - Interactive Route Planning
    open var route: Route? {
        didSet {
            self.reload()
        }
    }
    open var directionOrigin: Station?
    open var directionDestination: Station? 
    @IBAction private func cancelDirections(sender: UIBarButtonItem?) {
        self.directionOrigin = nil
        self.directionDestination = nil
        self.setupRoute()
    }
    func setupRoute() {
        if directionOrigin == nil && directionDestination == nil {
            self.navigationItem.setRightBarButton(nil, animated: true)
            self.title = "MetroMap"
        } else {
            self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelDirections)), animated: true)
            self.title = "Directions"
            if let name = directionOrigin?.name { self.title! += " from \(name)" }
            if let name = directionDestination?.name { self.title! += " to \(name)"}
        }
        if let origin = directionOrigin, let destination = directionDestination, let map = metroMap {
            route = Route(shortestOnMap: map, from: origin, to: destination)
        } else {
            route = nil
        }
    }
    override open func metroMap(_ metroMap: MetroMapView, shouldEmphasizeElement element: MetroMapView.Element) -> Bool {
        switch element {
        case .segment(let segment):
            return self.route?.segments.contains(segment) ?? false
        case .connection(let connection):
            return self.route?.segments.contains(connection) ?? false
        case .station(let station):
            guard let nodes = self.route?.steps else { return false }
            return nodes.first == station || nodes.last == station
        }
    }
    
}
