//
//  SearchResultsManager.swift
//  News
//
//  Created by 陈一鸣 on 4/17/20.
//  Copyright © 2020 陈一鸣. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol SearchResultsManagerDelegate {
    func didUpdateSearchResult(_ searchResultsManager: SearchResultsManager, news: [NewsModel])
}

struct SearchResultsManager {
    var delegate: SearchResultsManagerDelegate?
    func fetchResultNews(_ keyword: String) {
        performRequest(with: "\(Constants.searchUrl)\(keyword)")
    }
    
    func performRequest(with urlString: String) {
        if let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            AF.request(url, method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    var news: [NewsModel] = []
                    for i in 0..<json.count {
                        let cur_news = NewsModel(id: json[i]["id"].stringValue,
                                                 title: json[i]["title"].stringValue,
                                                 url: json[i]["url"].stringValue,
                                                 urlToImg: json[i]["urlToImg"].stringValue,
                                                 section: json[i]["section"].stringValue,
                                                 time: json[i]["time"].stringValue,
                                                 timeDiff: json[i]["timeDiff"].stringValue)
                        news.append(cur_news)
                    }
                    
                    self.delegate?.didUpdateSearchResult(self, news: news)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
