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
            let storyboard = UIStoryboard(name: "StationPopoverViewController", bundle: Bundle(for: StationPopoverViewController.self))
            let viewController: StationPopoverViewController
            if UIDevice.current.userInterfaceIdiom == .pad {
                let navController = storyboard.instantiateInitialViewController() as! UINavigationController
                viewController = navController.topViewController as! StationPopoverViewController
                viewController.station = station
                self.stationViewController = viewController
                viewController.preferredContentSize = CGSize(width: 320, height: 300)
                viewController.mapViewController = self
                navController.modalPresentationStyle = .popover
                navController.popoverPresentationController?.delegate = viewController
                navController.popoverPresentationController?.sourceView = self.metroMapView
                navController.popoverPresentationController?.sourceRect = frame
                navController.popoverPresentationController?.passthroughViews = [self.metroMapView]
                self.present(navController, animated: true, completion: nil)
            } else {
                viewController = storyboard.instantiateViewController(withIdentifier: "RootViewController") as! StationPopoverViewController
                viewController.mapViewController = self
                viewController.station = station
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            self.stationViewController = viewController
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
            guard let lineLayers = self.metroMapView.lineLayer.sublayers as? [LineLayer] else {return}
            for layer in lineLayers {
                layer.draw()
            }
        }
    }
    open var directionOrigin: Station?
    open var directionDestination: Station? 
    @IBAction private func cancelDirections(sender: UIBarButtonItem?) {
        self.directionOrigin = nil
        self.directionDestination = nil
        self.clearRoute()
    }
    func setupRoute() {
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .cancel,target: self, action: #selector(cancelDirections)), animated: true)
        self.title = "Directions"
        if let name = directionOrigin?.name { self.title! += " from \(name)" }
        if let name = directionDestination?.name { self.title! += " to \(name)"}
        if let origin = self.directionOrigin, let destination = self.directionDestination, let map = self.metroMap {
            route = Route(shortestOnMap: map, from: origin, to: destination)
        }
    }
    func clearRoute() {
        self.navigationItem.setRightBarButton(nil, animated: true)
        self.title = "MetroMap"
        self.route = nil
    }
    func setupRoute(line: Line) {
        self.route = Route(line: line)
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelDirections)), animated: true)
        self.title = line.name
    }
    override open func metroMap(_ metroMap: MetroMapView, shouldEmphasizeElement element: MetroMapView.Element) -> Bool {
        switch element {
        case .segment(let segment):
            return self.route?.segments.contains(segment) ?? true
        case .connection(let connection):
            return self.route?.segments.contains(connection) ?? false
        case .station(let station):
            return self.route?.steps.contains(station) ?? true
        }
    }
    
}
