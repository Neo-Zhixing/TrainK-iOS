//
//  StationPopoverViewController.swift
//  MetroMap
//
//  Created by 张之行 on 3/23/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit

open class StationPopoverViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet open var directionButton: UIButton!
    open var station: Station?
    open weak var mapViewController: MetroMapInteractiveViewController?
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    private func setupViews() {
        navigationItem.title = station?.name
        if let origin = mapViewController?.directionOrigin {
            directionButton.titleLabel?.text?.append("\nfrom \(origin.name ?? "Untitled")")
        }
        directionButton.isEnabled = mapViewController?.directionDestination != station && mapViewController?.directionOrigin != station
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction open func directionButtonPressed(sender: UIButton?) {
        if mapViewController?.directionOrigin == nil {
            mapViewController?.directionOrigin = self.station
        } else {
            mapViewController?.directionDestination = self.station
        }
        mapViewController?.setupRoute()
        self.dismiss()
    }
    @objc open func dismiss(sender: AnyObject? = nil) {
        self.dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - Table View
    lazy var lines: [Line] = {
        var lines:[Line] = []
        guard let allLines = self.mapViewController?.metroMap?.lines,
        let station = self.station else {return lines}
        for line in allLines {
            for segment in line.segments {
                if segment.from == station || segment.to == station {
                    lines.append(line)
                    break
                }
            }
        }
        return lines
    }()
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lines.count
    }
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let line = lines[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Line")!
        cell.textLabel?.text = line.name
        cell.accessoryView?.backgroundColor = line.color
        return cell
    }
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let line = self.lines[indexPath.row]
        mapViewController?.setupRoute(line: line)
        self.dismiss()
    }
}
