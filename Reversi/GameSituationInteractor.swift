//
//  GameSituationInteractor.swift
//  Reversi
//
//  Created by 松居麻衣 on 2020/05/05.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

protocol GameSituationUsecase: AnyObject {
    // TODO: - gameDataはstructとかにできたらやって
    func save(gameData: String)
    func get(completion: (Result<GameSituation, FileIOError>) -> Void)
}

class GameSituationInteractor {
    private let dataStore: GameSituationRepository
    
    init(dataStore: GameSituationRepository = GameSituationDataStore()) {
        self.dataStore = dataStore
    }
    
    
}

extension GameSituationInteractor: GameSituationUsecase {
    func save(gameData: String) {
        dataStore.save(gameData: gameData)
    }
    
    func get(completion: (Result<GameSituation, FileIOError>) -> Void) {
        dataStore.load() { result in
            switch result {
            case .success(let input):
                var lines: ArraySlice<Substring> = input.split(separator: "\n")[...]
                
                var turn: Disk?
                var players: [Player] = []
                var board = Board()
                
                guard var line = lines.popFirst() else {
                    // TODO: - エラー処理
                    completion(.failure(FileIOError.read(path: nil, cause: nil)))
                    return
                }
                
                do { // turn
                    guard
                        let diskSymbol = line.popFirst(),
                        let disk = Optional<Disk>(symbol: diskSymbol.description)
                    else {
                        // TODO: - エラー処理
                        completion(.failure(FileIOError.read(path: nil, cause: nil)))
                        return
                    }
                    
                    turn = disk
                }

                // players
                for side in Disk.sides {
                    guard
                        let playerSymbol = line.popFirst(),
                        let playerNumber = Int(playerSymbol.description),
                        let player = Player(rawValue: playerNumber)
                    else {
                        // TODO: - エラー処理
                        completion(.failure(FileIOError.read(path: nil, cause: nil)))
                        return
                    }
                    players.append(player)
                }
                
                // board
                guard lines.count == board.height else {
                    // TODO: - エラー処理
                    completion(.failure(FileIOError.read(path: nil, cause: nil)))
                    return
                }
                
                var y = 0
                while let line = lines.popFirst() {
                    var x = 0
                    for character in line {
                        let disk = Disk?(symbol: "\(character)").flatMap { $0 }
                        board.cellContents.append((x: x, y: y, disk: disk))
                        x += 1
                    }
                    guard x == board.width else {
                        // TODO: - エラー処理
                        completion(.failure(FileIOError.read(path: nil, cause: nil)))
                        return
                    }
                    y += 1
                }
                guard y == board.height else {
                    // TODO: - エラー処理
                    completion(.failure(FileIOError.read(path: nil, cause: nil)))
                    return
                }
                
                let gameSituation = GameSituation(board: board, players: players, turn: turn)
                completion(.success(gameSituation))
                
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
    }
}
