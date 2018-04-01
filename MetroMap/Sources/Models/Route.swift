//
//  Route.swift
//  MetroMap
//
//  Created by 张之行 on 3/22/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import Foundation

open class Route {
    open var steps: [Node]
    open var segments: [Segment]
    
    public init?(line: Line) {
        var nodes: Set<Node> = []
        self.segments = line.segments
        for segment in line.segments {
            nodes.insert(segment.from)
            nodes.insert(segment.to)
        }
        self.steps = Array(nodes)
    }
    
    public init?(shortestOnMap map:MetroMap, from: Node, to: Node) {
        // Essencially an implementation of Dijkstra's algorithm
        var unvisited = map.nodes.union(map.stations as Set<Node>) // All Nodes on the map
        var segments:Set<Segment> = map.connections // Initialize segments with all connections
        for line in map.lines {
            segments.formUnion(Set(line.segments))
        } // Adding segments on the lines to the segments
        // Now segments contains all connections on the map
        var distances:[Node: Float] = [:]
        var predecessors:[Node: Node] = [:]
        for node in unvisited {
            distances[node] = Float.infinity
        }
        distances[from] = 0
        while !unvisited.isEmpty {
            // Calculating unsettled nodes with min distance
            
            guard let nodeVisiting = unvisited.min(by: {distances[$0]! < distances[$1]!}) else {
                return nil
            } // There's no such route connection two nodes.
            unvisited.remove(nodeVisiting)
            if (nodeVisiting == to) { break }
            var segmentMap:[Node:Segment] = [:] // segmentMap[neighboringNode] = the segment from nodeVisiting to neighboringNode
            for segment in segments {
                if segment.from == nodeVisiting {
                    segmentMap[segment.to] = segment
                }
                else if segment.to == nodeVisiting {
                    segmentMap[segment.from] = segment
                }
            }
            
            for (neighboringNode, segmentToNeighboringNode) in segmentMap {
                let newDistance = distances[nodeVisiting]! + segmentToNeighboringNode.length
                if newDistance < distances[neighboringNode]! {
                    distances[neighboringNode] = newDistance
                    predecessors[neighboringNode] = nodeVisiting
                }
            }
        }
        self.steps = [to]
        self.segments = []
        var u = to
        // Now we have all the predecessors,
        // Use reverse iteration to calculate the steps and the segments.
        while predecessors[u] != nil {
            let pre = predecessors[u]!
            self.steps.insert(pre, at: 0)
            for segment in segments {
                if (segment.to == u && segment.from == pre) || (segment.from == u && segment.to == pre) {
                    self.segments.insert(segment, at: 0)
                    break
                }
            }
            u = pre
        }
        if self.steps.count == 0 { return nil }
    }
}
