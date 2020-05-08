//
//  NewsManager.swift
//  News
//
//  Created by 陈一鸣 on 4/12/20.
//  Copyright © 2020 陈一鸣. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol NewsManagerDelegate {
    func didUpdateNews(_ newsManager: NewsManager, news: [NewsModel])
}

struct NewsManager {
    var delegate: NewsManagerDelegate?
    
    func fetchNews() {
        performRequest(with: Constants.topNewsUrl)
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
                    
                    self.delegate?.didUpdateNews(self, news: news)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
