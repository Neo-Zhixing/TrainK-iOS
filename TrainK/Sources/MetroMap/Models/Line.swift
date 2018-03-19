//
//  Line.swift
//  TrainK
//
//  Created by 张之行 on 3/19/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Line:Hashable {
    public var id: Int
    public var name: String?
    public var segments: [Segment]

    public init(data: JSON, onMap map: MetroMap){
        self.id = data["id"].intValue
        self.name = data["name"].stringValue
        self.segments = data["segments"].arrayValue.map {
            (data) in
            return Segment(data: data, onMap: map)
        }
    }
    public var hashValue: Int {
        return self.id
    }
    public static func ==(lhs: Line, rhs: Line) -> Bool {
        return lhs.id == rhs.id
    }
}

public class Segment {
    public enum DrawingMode:String {
        case line
        case square
        case triangle
        case curve
    }
    var from: Node?
    var to: Node
    var inverse: Bool = false
    var drawingMode: DrawingMode = .line
    
    init(data: JSON, onMap map:MetroMap) {
        let nodes = map.nodeMapping
        self.to = nodes[data["to"].intValue]!
        if let fromNodeID = data["from"].int {
            self.from = nodes[fromNodeID]
        }
        if let inverse = data["inverse"].bool {
            self.inverse = inverse
        }
        if let drawingModeStr = data["mode"].string, let drawingMode = Segment.DrawingMode(rawValue: drawingModeStr) {
            self.drawingMode = drawingMode
        }
    }
}
