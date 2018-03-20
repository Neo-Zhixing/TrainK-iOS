//
//  MetroMapViewController.swift
//  TrainK
//
//  Created by 张之行 on 3/19/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

class MetroMapViewController: UIViewController, UIScrollViewDelegate, MetroMapViewDelegate {
    @IBOutlet var metroMapView: MetroMapView!
    @IBOutlet var scrollView: UIScrollView?
    var metroMap: MetroMap? {
        didSet {
            self.metroMapView.datasource = self.metroMap
            guard let metroMap = self.metroMap else { return }
            self.scrollView?.contentSize = self.metroMapView.frame.size
            self.scrollView?.maximumZoomScale = metroMap.configs.maxZoom
            self.scrollView?.minimumZoomScale = metroMap.configs.minZoom
            self.scrollView?.backgroundColor = metroMap.configs.backgroundColor
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.metroMapView.delegate = self
        self.scrollView?.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var selectionPopoverViewController:UIViewController?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
    
    func metroMap(_ metroMap: MetroMapView, selectStation station: Station, onFrame frame: CGRect) {
        print(station.position)
        self.performSegue(withIdentifier: "StationPopover", sender: (station, frame))
    }
    func metroMap(_ metroMap: MetroMapView, deselectStation station: Station) {
        self.selectionPopoverViewController?.dismiss(animated: false, completion: nil)
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return metroMapView
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.metroMapView.delectedAll()
    }
    

}
