//
//  GithubService.swift
//  RX
//
//  Created by Avtar Singh on 04/01/18.
//  Copyright © 2018 Avtar Singh. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
enum ServiceError:Error{
    case cannotParse
}

class GithubService{
    private let session :URLSession!
    
    init(session:URLSession = URLSession.shared) {
        self.session = session
    }
    
    /// - Returns: a list of languages from GitHub.
    public func getLanguageList()->Observable<[String]>{
       return Observable.just([
        "Swift",
        "Objective-C",
        "Java",
        "C",
        "C++",
        "Python",
        "C#"
        ])
    }
    
    /// - Parameter language: Language to filter by
    /// - Returns: A list of most popular repositories filtered by langugage
    public func getMostPopularRepositeries(byLanguage language: String) -> Observable<[Repository]>{
        let ecodedLanguage = language.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: "https://api.github.com/search/repositories?q=language:\(ecodedLanguage)&sort=stars")!
        
       return session.rx
        .json(url: url)
        .flatMap { json throws -> Observable<[Repository]> in
            guard
                let json = json as? [String: Any],
                let itemsJSON = json["items"] as? [[String: Any]]
                else { return Observable.error(ServiceError.cannotParse) }
            
            let repositories = itemsJSON.flatMap(Repository.init)
            return Observable.just(repositories)
            
        }
        
    }
}
