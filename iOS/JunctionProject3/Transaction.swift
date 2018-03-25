//
//  Transaction.swift
//  JunctionProject3
//
//  Created by 塗木冴 on 2018/03/24.
//  Copyright © 2018年 SaeNuruki. All rights reserved.
//

import Foundation
import ObjectMapper

public struct Transaction: Mappable {

    public var name: String = ""
    public var price: String = ""
    public var size: String = ""

    public init() {}

    init(name: String, price: String, size: String) {
        self.name = name
        self.price = price
        self.size = size
    }

    public init?(map: Map) {
        self.init()
        mapping(map: map)
    }

    public mutating func mapping(map: Map) {
        name <- map["name"]
        price <- map["price"]
        size <- map["size"]
    }
}

