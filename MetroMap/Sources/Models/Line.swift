//
//  Line.swift
//  TrainK
//
//  Created by 张之行 on 3/19/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit
import SwiftyJSON

open class Line:Hashable {
    open var id: Int
    open var name: String?
    open var segments: [Segment] = []
    open var color = UIColor.red

    public init(data: JSON, onMap map: MetroMap){
        self.id = data["id"].intValue
        if let name = data["name"].string {
            self.name = name
        }
        self.segments = data["segments"].arrayValue.map {
            (data) in
            return Segment(data: data, onMap: map)
        }
        if let colorHexStr = data["color"].string {
            self.color = UIColor(hex: colorHexStr)
        }
    }
    public init(id: Int) {
        self.id = id
    }
    open var hashValue: Int {
        return self.id
    }
    open static func ==(lhs: Line, rhs: Line) -> Bool {
        return lhs.id == rhs.id
    }
}

open class Segment {
    public enum DrawingMode:String {
        case line
        case square
        case triangle
        case curve
    }
    open var from: Node?
    open var to: Node
    open var inverse: Bool = false
    open var drawingMode: DrawingMode = .line
    
    public init(data: JSON, onMap map:MetroMap) {
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
