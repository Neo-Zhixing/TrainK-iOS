//
//  MetroMapInteractiveViewController.swift
//  MetroMap
//
//  Created by 张之行 on 3/21/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

open class MetroMapInteractiveViewController: MetroMapScrollableViewController, UISearchControllerDelegate {
    open var stationViewController:StationPopoverViewController?
    var searchResultController: StationSearchResultController!
    open override func viewDidLoad() {
        super.viewDidLoad()
        searchResultController = StationSearchResultController()
        searchResultController.metroMap = self.metroMap
        searchResultController.mapViewController = self
        self.navigationItem.searchController = UISearchController(searchResultsController: searchResultController)
        self.navigationItem.searchController?.delegate = self
        self.navigationItem.searchController?.searchResultsUpdater = searchResultController
        self.definesPresentationContext = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchBtnClicked))
    }
    @objc func searchBtnClicked(sender: Any?) {
        self.navigationItem.searchController?.searchBar.becomeFirstResponder()
    }
    open override func metroMap(_ metroMap: MetroMapView, willSelectElement element: MetroMapView.Element, onFrame frame: CGRect) {
        switch  element {
        case .station(let station):
            let viewController = StationPopoverViewController(station)
            viewController.mapViewController = self
            self.stationViewController = viewController
            if UIDevice.current.userInterfaceIdiom == .pad {
                viewController.modalPresentationStyle = .popover
                viewController.popoverPresentationController?.delegate = viewController
                viewController.popoverPresentationController?.sourceView = self.metroMapView
                viewController.popoverPresentationController?.sourceRect = frame
                viewController.popoverPresentationController?.passthroughViews = [self.metroMapView]
                self.present(viewController, animated: true, completion: nil)
            } else {
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        default:
            ()
        }

    }

    open override func metroMap(_ metroMap: MetroMapView, willDeselectElement element: MetroMapView.Element) {
        if self.navigationController?.topViewController == self {
            self.stationViewController?.dismiss(animated: false, completion: nil)
            self.stationViewController = nil
        } else {
            self.navigationController?.popToViewController(self, animated: true)
        }
    }
    open override func metroMap(_ metroMap: MetroMapView, canSelectElement element: MetroMapView.Element) -> Bool {
        return true
    }
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.metroMapView.deselectAll()
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
            return self.route?.segments.contains(segment) ?? true
        case .connection(let connection):
            return self.route?.segments.contains(connection) ?? false
        case .station(let station):
            guard let nodes = self.route?.steps else { return true }
            return nodes.first == station || nodes.last == station
        }
    }
    
}
