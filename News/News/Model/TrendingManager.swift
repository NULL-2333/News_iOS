//
//  TrendingManager.swift
//  News
//
//  Created by 陈一鸣 on 4/14/20.
//  Copyright © 2020 陈一鸣. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Charts

protocol TrendingManagerDelegate {
    func didUpdateTrending(_ trendingManager: TrendingManager, trending: [ChartDataEntry])
}

struct TrendingManager {
    var delegate: TrendingManagerDelegate?
    var trendingData: [ChartDataEntry] = []
    func fetchTrending(_ keyword: String) {
        performRequest(with: "\(Constants.trendingUrl)\(keyword)")
    }
    
    func performRequest(with urlString: String) {
        if let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            AF.request(url, method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    var trendingData: [ChartDataEntry] = []
                    for i in 0..<json.count {
                        let data = ChartDataEntry(x: Double(json[i]["x"].intValue), y: Double(json[i]["y"].intValue))
                        trendingData.append(data)
                    }
                    self.delegate?.didUpdateTrending(self, trending: trendingData)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
