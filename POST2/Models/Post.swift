//
//  Post.swift
//  POST2
//
//  Created by Nathan Andrus on 2/4/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import Foundation

struct Post: Codable {
    let username: String
    let timestamp: TimeInterval
    let text: String
    
    init(username: String, timestamp: TimeInterval = Date().timeIntervalSince1970, text: String) {
        self.username = username
        self.text = text
        self.timestamp = timestamp
    }
    
    var  timeQueryStamp: TimeInterval {
        return timestamp - 0.00001
    }
}

