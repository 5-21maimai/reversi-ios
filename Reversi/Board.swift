//
//  Board.swift
//  Reversi
//
//  Created by 松居麻衣 on 2020/05/06.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

struct Board {
    let width: Int = 8
    let height: Int = 8
    
    var cellContents: [(x: Int, y: Int, disk: Disk?)] = []
}
