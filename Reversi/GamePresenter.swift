//
//  ReversiPresenter.swift
//  Reversi
//
//  Created by 松居麻衣 on 2020/05/05.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

protocol GamePresentation: AnyObject {
    func viewDidLoad()
    func save() //メソッド名はダミー
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
    
    func viewDidLoad() {
        
        // ゲームの状態をファイルから読み出す。読み出せなかったら初期化する
        interactor.get() { result in
            switch result {
            case .success(let gameSituation):
                view?.showGame(situation: gameSituation)
                
            case .failure(let error):
                // TODO: - newGameする
                print("ゲームの初期化をする")
            }
            
            
        }
        
    }
    
    func save() {
        
    }
}
