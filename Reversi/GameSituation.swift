//
//  GameSituation.swift
//  Reversi
//
//  Created by 松居麻衣 on 2020/05/06.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

struct GameSituation {
    var board: Board
    var players: [Player]
    var turn: Disk?
}
