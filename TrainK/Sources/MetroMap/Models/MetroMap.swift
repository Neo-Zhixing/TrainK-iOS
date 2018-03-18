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

public struct Station {
    public enum Level:String {
        case minor
        case major
        case interchange
        case intercity
    }
    public var position: CGPoint
    public var name: String
    public var level: Level
    
    public init(data: JSON) {
        let position = data["position"]
        self.position = CGPoint(x: position[0].doubleValue, y: position[1].doubleValue)
        self.name = data["name"].stringValue
        
        let typeName = data["type"].string
        self.level = typeName == nil ? Level.major : Level(rawValue: typeName!)!
    }
}

public class MetroMap: NSObject {
    public var stations: [Station] = []
    public var stationIcons: [Station.Level : Data] = [:]
    
    public var spacing: Double = 10
}

public extension MetroMap {
    convenience init(data: JSON) {
        self.init()
        self.spacing = data["configs"]["spacing"].double ?? self.spacing
        for (levelName, iconName) in data["resources"]["stationIcons"] {
            let level = Station.Level(rawValue: levelName)!
            let iconURL = Bundle.main.url(forResource: iconName.stringValue, withExtension: "svg")!
            if let data = try? Data(contentsOf: iconURL) {
                self.stationIcons[level] = data
            }
        }
        for station in data["stations"].arrayValue {
            self.stations.append(Station(data: station))
        }
    }
}
