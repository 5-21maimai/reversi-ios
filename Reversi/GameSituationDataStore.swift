//
//  GameSituationDataStore.swift
//  Reversi
//
//  Created by 松居麻衣 on 2020/05/05.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

protocol GameSituationRepository: AnyObject {
    func save(gameData: String)
    func load(completion: (Result<String, FileIOError>) -> Void)
}

class GameSituationDataStore {
    private var path: String {
        (NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first! as NSString).appendingPathComponent("Game")
    }
}

extension GameSituationDataStore: GameSituationRepository {
    func save(gameData: String) {
        do {
            try gameData.write(toFile: path, atomically: true, encoding: .utf8)
        } catch let error {
            // TODO: - エラー処理
//            throw FileIOError.read(path: path, cause: error)
        }
    }
    
    func load(completion: (Result<String, FileIOError>) -> Void) {
        
        do {
            let input = try String(contentsOfFile: path, encoding: .utf8)
            completion(.success(input))
            
        } catch let error {
            completion(.failure(FileIOError.write(path: path, cause: error)))
        }
    }
}

enum FileIOError: Error {
    case write(path: String, cause: Error?)
    case read(path: String, cause: Error?)
}
