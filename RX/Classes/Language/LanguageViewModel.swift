//
//  LanguageViewModel.swift
//  RX
//
//  Created by Avtar Singh on 09/01/18.
//  Copyright © 2018 Avtar Singh. All rights reserved.
//

import Foundation
import RxSwift

class LanguageViewModel{
    
    //MARK: - Inputs
    var selectLanguage : AnyObserver<String>
    var cancel : AnyObserver<Void>! = nil
    
    //MARK: - Outputs
    let languages : Observable<[String]>
    var didSelectLanguage:Observable<String>
    var didCancel: Observable<Void>
    
    init(githubService:GithubService = GithubService()) {
        self.languages = githubService.getLanguageList()
        
        let _selectedLanguage = PublishSubject<String>()
        self.selectLanguage = _selectedLanguage.asObserver()
        self.didSelectLanguage = _selectedLanguage.asObservable()
        
        let _cancel = PublishSubject<Void>()
        self.cancel = _cancel.asObserver()
        self.didCancel = _cancel.asObservable()
    }
}
