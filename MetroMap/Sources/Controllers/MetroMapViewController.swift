//
//  MetroMapViewController.swift
//  TrainK
//
//  Created by 张之行 on 3/19/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

open class MetroMapViewController: UIViewController, MetroMapViewDelegate {
    
    @IBOutlet open var metroMapView: MetroMapView!
    
    open var metroMap: MetroMap?
    
    public init(map: MetroMap) {
        super.init(nibName: nil, bundle: nil)
        self.metroMapView = MetroMapView()
        self.metroMapView.datasource = map
        self.metroMap = map
        self.view = self.metroMapView
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
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open func metroMap(_ metroMap: MetroMapView, willSelectStation station: Station, onFrame frame: CGRect) {}
    open func metroMap(_ metroMap: MetroMapView, willDeselectStation station: Station) {}
    open func metroMap(_ metroMap: MetroMapView, didSelectStation station: Station, onFrame frame: CGRect) {}
    open func metroMap(_ metroMap: MetroMapView, didDeselectStation station: Station) {}
    open func metroMap(_ metroMap: MetroMapView, moveStation station: Station, to point: CGPoint, withTouch touch: UITouch) {}
    open func metroMap(_ metroMap: MetroMapView, canSelectStation station: Station) -> Bool {
        return false
    }
}

open class MetroMapScrollableViewController: MetroMapViewController, UIScrollViewDelegate {
    @IBOutlet open var scrollView: UIScrollView?
    
    public override init(map: MetroMap) {
        super.init(map: map)
        let scrollView = UIScrollView()
        self.scrollView = scrollView
        scrollView.addSubview(self.metroMapView)
        self.view = scrollView
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func reload() {
        super.reload()
        self.scrollView?.delegate = self
        self.scrollView?.scrollsToTop = false
        self.scrollView?.contentSize = self.metroMapView.frame.size
        self.scrollView?.maximumZoomScale = metroMap?.configs.maxZoom ?? 1
        self.scrollView?.minimumZoomScale = metroMap?.configs.minZoom ?? 2
        self.scrollView?.backgroundColor = metroMap?.configs.backgroundColor
    }
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return metroMapView
    }
}
