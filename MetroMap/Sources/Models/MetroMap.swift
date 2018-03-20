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

open class MetroMap: NSObject {
    open class Configs {
        open var size:CGSize
        open var maxZoom: CGFloat
        open var minZoom: CGFloat
        open var spacing: CGFloat = 10
        open var backgroundColor = UIColor.white
        
        public init(json data: JSON) {
            self.size = CGSize(
                width: data["size"][0].doubleValue,
                height: data["size"][1].doubleValue
            )
            self.maxZoom = CGFloat(data["maxZoom"].double ?? 100.0)
            self.minZoom = CGFloat(data["minZoom"].double ?? 0.1)
            if let hexStr = data["backgroundColor"].string {
                self.backgroundColor = UIColor(hex: hexStr)
            }
        }
    }
    open var configs:Configs
    open var nodes: Set<Node> = []
    open var stations: Set<Station> = []
    open var connections: [Segment] = []
    
    open var nodeMapping: [Int:Node] = [:]
    
    open var stationIcons: [Station.Level : Data] = [:]
    
    open var lines: Set<Line> = []

    public convenience init?(data: Data){
        guard let json = try? JSON(data: data) else {return nil}
        self.init(json: json)
    }
    public init(json data: JSON) {
        self.configs = Configs(json: data["configs"])
        super.init()
        for (levelName, iconName) in data["resources"]["stationIcons"] {
            let level = Station.Level(rawValue: levelName)!
            let bundle = Bundle(for: type(of:self))
            let iconURL = bundle.url(forResource: iconName.stringValue, withExtension: "svg")!
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
