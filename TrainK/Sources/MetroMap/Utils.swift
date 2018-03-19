//
//  Utils.swift
//  TrainK
//
//  Created by 张之行 on 3/20/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import Foundation
import CoreGraphics

func point(from: CGPoint, to: CGPoint, apart r: CGFloat) -> CGPoint {
    let width = to.x - from.x
    let height = to.y - from.y
    let L = sqrt(width * width + height * height)
    let l = L + r
    return CGPoint(
        x: from.x + (L*width) / l,
        y: from.y + (L*height) / l
    )
}
