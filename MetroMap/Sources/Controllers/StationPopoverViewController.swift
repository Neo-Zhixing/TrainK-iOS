//
//  StationPopoverViewController.swift
//  MetroMap
//
//  Created by 张之行 on 3/23/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

open class StationPopoverViewController: UIViewController {
    @IBOutlet open var stationNameLabel: UILabel!
    @IBOutlet open var directionButton: UIButton!
    open var station: Station
    open weak var mapViewController: MetroMapInteractiveViewController?
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    private func setupViews() {
        stationNameLabel?.text = station.name
        if let origin = mapViewController?.directionOrigin {
            directionButton.titleLabel?.text?.append("\nfrom \(origin.name ?? "Untitled")")
        }
        directionButton.isEnabled = mapViewController?.directionDestination != station && mapViewController?.directionOrigin != station
    }
    
    init(_ station: Station) {
        self.station = station
        super.init(nibName: "StationPopoverViewController", bundle: Bundle(for: StationPopoverViewController.self))
        self.preferredContentSize = CGSize(width: 320, height: 300)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @IBAction open func directionButtonPressed(sender: UIButton?) {
        if mapViewController?.directionOrigin == nil {
            mapViewController?.directionOrigin = self.station
        } else {
            mapViewController?.directionDestination = self.station
        }
        mapViewController?.setupRoute()
        self.dismiss(animated: true)
    }
}
