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
    public var connections: [Segment] = []
    
    public var nodeMapping: [Int:Node] = [:]
    
    public var stationIcons: [Station.Level : Data] = [:]
    
    public var lines: Set<Line> = []

    public var spacing: Double = 10

    public init(data: JSON) {
        super.init()
        for (levelName, iconName) in data["resources"]["stationIcons"] {
            let level = Station.Level(rawValue: levelName)!
            let iconURL = Bundle.main.url(forResource: iconName.stringValue, withExtension: "svg")!
            if let data = try? Data(contentsOf: iconURL) {
                self.stationIcons[level] = data
            }
        }
        for jsondata in data["stations"].arrayValue {
            let station = Station(data: jsondata)
            self.stations.insert(station)
        }
        for jsondata in data["nodes"].arrayValue {
            let node = Node(data: jsondata)
            self.nodes.insert(node)
        }

        // Generating Node Mappings so that we could fetch the node using its id
        for node in self.stations {
            self.nodeMapping[node.id] = node
        }
        for node in self.nodes {
            self.nodeMapping[node.id] = node
        }
        
        
        for jsondata in data["connections"].arrayValue {
            let con = Segment(data: jsondata, onMap: self)
            self.connections.append(con)
        }
        
        // Creating Lines
        for line in data["lines"].arrayValue {
            let line = Line(data: line, onMap: self)
            self.lines.insert(line)
        }
    }
}
