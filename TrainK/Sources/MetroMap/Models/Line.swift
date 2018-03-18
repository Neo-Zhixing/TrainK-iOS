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
    public class Segment {
        public enum DrawingMode:String {
            case direct
            case square
            case triangle
            case curve
        }
        var from: Node?
        var to: Node
        var inverse: Bool = false
        var drawingMode: DrawingMode = .triangle
        
        init(to: Node) {
            self.to = to
        }
    }
    public var id: Int
    public var name: String?
    public var segments: [Segment]

    public init(data: JSON, nodes: [Int:Node]){
        self.id = data["id"].intValue
        self.name = data["name"].stringValue
        self.segments = data["segments"].arrayValue.map {
            (data) in
            let segment = Segment(to: nodes[data["to"].intValue]!)
            if let fromNodeID = data["from"].int {
                segment.from = nodes[fromNodeID]
            }
            if let inverse = data["inverse"].bool {
                segment.inverse = inverse
            }
            if let drawingModeStr = data["drawingMode"].string, let drawingMode = Segment.DrawingMode(rawValue: drawingModeStr) {
                segment.drawingMode = drawingMode
            }
            return segment
        }
    }
    public var hashValue: Int {
        return self.id
    }
    public static func ==(lhs: Line, rhs: Line) -> Bool {
        return lhs.id == rhs.id
    }
}
