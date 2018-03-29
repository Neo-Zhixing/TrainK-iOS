//
//  ViewController.swift
//  TrainK
//
//  Created by 张之行 on 3/19/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit
import MetroMap

class ViewController: MetroMapInteractiveViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = Bundle.main.url(forResource: "hefei", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        self.metroMap = MetroMap(data: data)
        metroMapView.datasource = self.metroMap
        self.reload()
        scrollView?.zoom(to: metroMapView.frame, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

