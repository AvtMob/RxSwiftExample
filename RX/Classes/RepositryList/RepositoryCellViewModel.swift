//
//  RepositoryCellViewModel.swift
//  RX
//
//  Created by Avtar Singh on 10/01/18.
//  Copyright © 2018 Avtar Singh. All rights reserved.
//

import Foundation
class RepositoryCellViewModel {
    let name: String
    let description: String
    let starsCountText: String
    let url: URL
    
    init(repository: Repository) {
        self.name = repository.fullName
        self.description = repository.description
        self.starsCountText = "⭐️ \(repository.starsCount)"
        self.url = URL(string: repository.url)!
    }
}
