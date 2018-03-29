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
        for json in data["segments"].arrayValue {
            if let newSegment = Segment(data: json, forNodes: nodes, lastSegmentNode: lastSegment?.to) {
                self.segments.append(newSegment)
                lastSegment = newSegment
            }
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
    
    public init?(data: JSON, forNodes nodes:[Int: Node], lastSegmentNode: Node? = nil) {
        guard let toID = data["to"].int, let to = nodes[toID] else {
            print("MetroMap: Compile Segment error. Can't get node 'to'")
            return nil
        }
        self.to = to
        if let l = lastSegmentNode {
            self.from = l
        } else {
            guard let fromID = data["from"].int, let from = nodes[fromID]  else {
                print("MetroMap: Compile Segment error. Can't get node 'from'")
                return nil
            }
            self.from = from
        }
        
        if let inverse = data["inverse"].bool {
            self.inverse = inverse
        }
        if let length = data["length"].float {
            self.length = length
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
