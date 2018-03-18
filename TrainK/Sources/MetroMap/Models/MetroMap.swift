//
//  MetroMap.swift
//  TrainK
//
//  Created by 张之行 on 3/19/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSVG

public class MetroMap: NSObject {
    public var nodes: Set<Node> = []
    public var stations: Set<Station> = []
    
    public var nodeMapping: [Int:Node] = [:]
    
    public var stationIcons: [Station.Level : Data] = [:]
    
    public var lines: Set<Line> = []

    public var spacing: Double = 10

    public init(data: JSON) {
        if let spacing = data["configs"]["spacing"].double {
            self.spacing = spacing
        }
        for (levelName, iconName) in data["resources"]["stationIcons"] {
            let level = Station.Level(rawValue: levelName)!
            let iconURL = Bundle.main.url(forResource: iconName.stringValue, withExtension: "svg")!
            if let data = try? Data(contentsOf: iconURL) {
                self.stationIcons[level] = data
            }
        }
        for stationJSON in data["stations"].arrayValue {
            let station = Station(data: stationJSON)
            self.stations.insert(station)
        }
        for nodeJSON in data["nodes"].arrayValue {
            let node = Node(data: nodeJSON)
            self.nodes.insert(node)
        }

        // Generating Node Mappings so that we could fetch the node using its id
        for node in self.stations {
            self.nodeMapping[node.id] = node
        }
        for node in self.nodes {
            self.nodeMapping[node.id] = node
        }
        
        // Creating Lines
        for line in data["lines"].arrayValue {
            
            let line = Line(data: line, nodes: self.nodeMapping)
            self.lines.insert(line)
        }
    }
}
