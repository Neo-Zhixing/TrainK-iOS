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
        let url = Bundle.main.url(forResource: "line", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        self.metroMap = MetroMap(data: data)
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

