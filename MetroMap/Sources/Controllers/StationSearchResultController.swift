//
//  StationSearchResultController.swift
//  MetroMap
//
//  Created by 张之行 on 3/31/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

class StationSearchResultController: UITableViewController, UISearchResultsUpdating {
    weak var mapViewController: MetroMapInteractiveViewController?
    var metroMap: MetroMap?
    var stations: [Station] = []
    init () {
        super.init(nibName: "StationSearchResultController", bundle: Bundle(for: StationSearchResultController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Station")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func updateSearchResults(for searchController: UISearchController) {
        guard let metroMap = self.metroMap else {return}
        self.stations = metroMap.stations.filter{
            station in
            let keyword = searchController.searchBar.text ?? ""
            guard let name = station.name else {return false}
            return name.contains(keyword)
        }
        self.tableView.reloadData()
    }
    
    // MARK: - TableView Datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Station", for: indexPath)
        cell.textLabel?.text = self.stations[indexPath.row].name
        return cell
    }
    
    // MARK: TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let station = self.stations[indexPath.row]
        self.dismiss(animated: true) {
            self.mapViewController?.metroMapView.select(.station(station))
        }
    }

}
