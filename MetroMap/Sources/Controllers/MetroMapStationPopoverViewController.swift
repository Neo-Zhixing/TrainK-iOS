//
//  MetroMapStationPopoverViewController.swift
//  TrainK
//
//  Created by 张之行 on 3/20/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

open class MetroMapStationPopoverViewController: UIViewController {
    open var station: Station?
    
    @IBOutlet open var stationNameLabel: UILabel?

    override open func viewDidLoad() {
        super.viewDidLoad()
        stationNameLabel?.text = station?.name
        // Do any additional setup after loading the view.
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
