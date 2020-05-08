//
//  DetailedNewsManager.swift
//  News
//
//  Created by 陈一鸣 on 4/14/20.
//  Copyright © 2020 陈一鸣. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol DetailedNewsManagerDelegate {
    func didUpdateNews(_ detailedNewsManager: DetailedNewsManager, detailedNews: DetailedNewsModel)
}

struct DetailedNewsManager {
    var delegate: DetailedNewsManagerDelegate?
    
    func fetchDetailedNews(_ article_id: String) {
         print(article_id)
        performRequest(with: "\(Constants.detailedNewsUrl)\(article_id)")
    }
    
    func performRequest(with urlString: String) {
        if let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            AF.request(url, method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let news = DetailedNewsModel(id: json["id"].stringValue,
                                                 title: json["title"].stringValue,
                                                 url: json["url"].stringValue,
                                                 urlToImg: json["urlToImg"].stringValue,
                                                 section: json["section"].stringValue,
                                                 time: json["time"].stringValue,
                                                 description: json["description"].stringValue)
                    self.delegate?.didUpdateNews(self, detailedNews: news)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
