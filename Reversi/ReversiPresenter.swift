//
//  ReversiPresenter.swift
//  Reversi
//
//  Created by 松居麻衣 on 2020/05/05.
//  Copyright © 2020 Yuta Koshizawa. All rights reserved.
//

import Foundation

protocol ReversiPresentation: AnyObject {
    
}

class ReversiPresenter {
    
    private weak var view: ReversiView?
    
    init(view: ReversiView) {
        self.view = view
    }
    
}

extension ReversiPresenter: ReversiPresentation {
    
}
