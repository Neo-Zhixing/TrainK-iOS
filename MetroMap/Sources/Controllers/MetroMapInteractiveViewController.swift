//
//  MetroMapInteractiveViewController.swift
//  MetroMap
//
//  Created by 张之行 on 3/21/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

open class MetroMapInteractiveViewController: MetroMapScrollableViewController {
    open var selectionPopoverViewController:UIViewController?
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "StationPopover",
            let (station, frame) = sender as? (Station, CGRect),
            let contentVC = segue.destination as? MetroMapStationPopoverViewController{
            contentVC.station = station
            self.selectionPopoverViewController = contentVC
            contentVC.popoverPresentationController?.passthroughViews = [metroMapView]
            contentVC.popoverPresentationController?.sourceRect = frame
        }
    }
    
    override open func metroMap(_ metroMap: MetroMapView, willSelectStation station: Station, onFrame frame: CGRect) {
        self.performSegue(withIdentifier: "StationPopover", sender: (station, frame))
    }
    override open func metroMap(_ metroMap: MetroMapView, willDeselectStation station: Station) {
        self.selectionPopoverViewController?.dismiss(animated: false, completion: nil)
    }
    override open func metroMap(_ metroMap: MetroMapView, canSelectStation station: Station) -> Bool {
        return true
    }
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.metroMapView.delectedAll()
    }
}
