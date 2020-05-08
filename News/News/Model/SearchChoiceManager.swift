//
//  SearchChoiceManager.swift
//  News
//
//  Created by 陈一鸣 on 4/17/20.
//  Copyright © 2020 陈一鸣. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol SearchChoiceManagerDelegate {
    func didUpdateSearchChoice(_ searchChoiceManager: SearchChoiceManager, searchChoices: [String])
}
struct SearchChoiceManager {
    let header: HTTPHeaders = [
        "Ocp-Apim-Subscription-Key": Constants.autoSuggestKey
    ]
    
    var delegate: SearchChoiceManagerDelegate?
    
    func fetchSearchChoices(_ keyword: String) {
        performRequest(keyword)
    }
    
    func performRequest(_ keyword: String) {
        if keyword.count < 3 {
            self.delegate?.didUpdateSearchChoice(self, searchChoices: [])
            return
        }
        let urlString = "\(Constants.autoSuggestUrl)\(keyword)"
        if let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            AF.request(url, method: .get, headers: header).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)["suggestionGroups"][0]["searchSuggestions"]
                    var choices: [String] = []
                    for i in 0..<json.count {
                        choices.append(json[i]["displayText"].stringValue)
                    }
                 self.delegate?.didUpdateSearchChoice(self, searchChoices: choices)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
