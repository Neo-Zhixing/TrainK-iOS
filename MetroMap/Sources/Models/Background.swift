//
//  Background.swift
//  MetroMap
//
//  Created by 张之行 on 3/22/18.
//  Copyright © 2018 begin Studio. All rights reserved.
//

import Foundation
import CoreGraphics
import SwiftyJSON

open class Background: NSObject {
    open var position = CGPoint()
    open var imageURL: URL
    init?(json: JSON) {
        if let x = json["position"][0].double, let y = json["position"][1].double {
            self.position = CGPoint(x: x, y: y)
        }
        if let imageName = json["image"].string,
            let imageURL = Bundle.main.url(forResource: imageName, withExtension: "svg") {
            self.imageURL = imageURL
        } else if let urlStr = json["imageURL"].string,
            let imageURL = URL(string: urlStr) {
            self.imageURL = imageURL
        } else {
            return nil
        }
    }
    init(url: URL) {
        self.imageURL = url
    }
}
