//
//  MetroMapViewController.swift
//  TrainK
//
//  Created by 张之行 on 3/19/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

open class MetroMapViewController: UIViewController, UIScrollViewDelegate, MetroMapViewDelegate {
    @IBOutlet open var metroMapView: MetroMapView!
    @IBOutlet open var scrollView: UIScrollView?
    open var metroMap: MetroMap?
    
    private init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    public convenience init(map: MetroMap, scroll: Bool = false) {
        self.init()
        self.metroMapView = MetroMapView()
        self.metroMapView.datasource = map
        self.metroMap = map
        if scroll{
            let scrollView = UIScrollView()
            self.scrollView = scrollView
            self.view = scrollView
        }
        self.view.addSubview(self.metroMapView)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.reload()
    }
    open func reload(){
        self.metroMapView.delegate = self
        self.metroMapView.datasource = self.metroMap
        self.metroMapView.reload()
        self.scrollView?.delegate = self
        self.scrollView?.contentSize = self.metroMapView.frame.size
        self.scrollView?.maximumZoomScale = metroMap?.configs.maxZoom ?? 1
        self.scrollView?.minimumZoomScale = metroMap?.configs.minZoom ?? 2
        self.scrollView?.backgroundColor = metroMap?.configs.backgroundColor
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    open func metroMap(_ metroMap: MetroMapView, selectStation station: Station, onFrame frame: CGRect) {
        print(station.position)
        self.performSegue(withIdentifier: "StationPopover", sender: (station, frame))
    }
    open func metroMap(_ metroMap: MetroMapView, deselectStation station: Station) {
        self.selectionPopoverViewController?.dismiss(animated: false, completion: nil)
    }
    
    
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return metroMapView
    }
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.metroMapView.delectedAll()
    }
    

}
