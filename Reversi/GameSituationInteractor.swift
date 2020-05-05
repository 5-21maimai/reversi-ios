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
    func load()
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
    
    func load() {
        
    }
    
    
}
