//
//  ReversiPresenter.swift
//  Reversi
//
//  Created by 松居麻衣 on 2020/05/05.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

protocol GamePresentation: AnyObject {
    
}

class GamePresenter {
    
    private weak var view: GameView?
    private let interactor: GameSituationUsecase
    
    init(view: GameView, interactor: GameSituationUsecase) {
        self.view = view
        self.interactor = interactor
    }
    
}

extension GamePresenter: GamePresentation {
    
}
