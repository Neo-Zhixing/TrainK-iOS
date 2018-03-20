//
//  MetroMapViewController.swift
//  TrainK
//
//  Created by 张之行 on 3/19/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

class MetroMapViewController: UIViewController, MetroMapViewDelegate {
    var metroMapView: MetroMapView! {
        get { return self.view as? MetroMapView }
        set { self.view = newValue }
    }
    var metroMap: MetroMap? {
        didSet {
            self.metroMapView.datasource = self.metroMap
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.metroMapView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "StationPopover",
            let (station, frame) = sender as? (Station, CGRect),
            let contentVC = segue.destination as? MetroMapStationPopoverViewController{
            contentVC.station = station
            contentVC.popoverPresentationController?.sourceRect = frame
        }
    }
    
    func metroMap(_ metroMap: MetroMapView, selectStation station: Station, onFrame frame: CGRect) {
        print(station.position)
        self.performSegue(withIdentifier: "StationPopover", sender: (station, frame ))
    }

}
