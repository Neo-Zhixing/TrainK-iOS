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
    open override func loadView() {
        super.loadView()
        if metroMapView == nil {
            metroMapView = MetroMapView()
            metroMapView.datasource = self.metroMap
        }
        
        self.view = metroMapView
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.title = "MetroMap"
        metroMapView.delegate = self
        metroMapView.datasource = self.metroMap
    }
    open func reload(){
        self.metroMapView.reload()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open func metroMap(_ metroMap: MetroMapView, canSelectElement element: MetroMapView.Element) -> Bool {return false}
    open func metroMap(_ metroMap: MetroMapView, willSelectElement element: MetroMapView.Element, onFrame frame: CGRect) {}
    open func metroMap(_ metroMap: MetroMapView, didSelectElement element: MetroMapView.Element, onFrame frame: CGRect) {}
    open func metroMap(_ metroMap: MetroMapView, moveElement element: MetroMapView.Element, to point: CGPoint, withTouch touch: UITouch) {}
    open func metroMap(_ metroMap: MetroMapView, willDeselectElement element: MetroMapView.Element) {}
    open func metroMap(_ metroMap: MetroMapView, didDeselectElement element: MetroMapView.Element) {}
    
    open func metroMap(_ metroMap: MetroMapView, shouldEmphasizeElement element: MetroMapView.Element) -> Bool {
        return false
    }
}

open class MetroMapScrollableViewController: MetroMapViewController, UIScrollViewDelegate {
    @IBOutlet open var scrollView: UIScrollView?
    
    open override func loadView() {
        super.loadView()
        if scrollView == nil {
            let scrollView = UIScrollView()
            scrollView.addSubview(self.metroMapView)
            self.scrollView = scrollView
        }
        self.view = scrollView
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView?.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public override init() {
        super.init()
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
    open func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.metroMapView.setScale(scrollView.zoomScale)
    }
}
