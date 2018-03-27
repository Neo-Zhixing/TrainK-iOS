//
//  Line.swift
//  TrainK
//
//  Created by 张之行 on 3/19/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import UIKit
import SwiftyJSON

open class Line: NSObject {
    open var id: Int
    open var name: String?
    open var segments: [Segment] = []
    open var color = UIColor.red

    public init(data: JSON, forNodes nodes: [Int:Node]){
        self.id = data["id"].intValue
        if let name = data["name"].string {
            self.name = name
        }
        var lastSegment: Segment?
        self.segments = data["segments"].arrayValue.map {
            data in
            var json = data
            if json["from"].int == nil, let lastNode = lastSegment?.to {
                json["from"].intValue = lastNode.id
            }
            let newSegment = Segment(data: json, forNodes: nodes)
            lastSegment = newSegment
            return newSegment
        }
        if let colorHexStr = data["color"].string {
            self.color = UIColor(hex: colorHexStr)
        }
        super.init()
    }
    public init(id: Int) {
        self.id = id
    }
    override open var hashValue: Int {
        return self.id
    }
    open static func ==(lhs: Line, rhs: Line) -> Bool {
        return lhs.id == rhs.id
    }
}

open class Segment: NSObject {
    public enum DrawingMode:String {
        case line
        case square
        case triangle
        case curve
        case parallel
    }
    open var from: Node
    open var to: Node
    open var length: Float = 1
    open var inverse: Bool = false
    open var drawingMode: DrawingMode = .line
    
    public init(data: JSON, forNodes nodes:[Int: Node]) {
        self.to = nodes[data["to"].intValue]!
        self.from = nodes[data["from"].intValue]!
        if let inverse = data["inverse"].bool {
            self.inverse = inverse
        }
        if let drawingModeStr = data["mode"].string, let drawingMode = Segment.DrawingMode(rawValue: drawingModeStr) {
            self.drawingMode = drawingMode
        }
    }
    public init(from: Node, to: Node) {
        self.from = from
        self.to = to
    }
}
