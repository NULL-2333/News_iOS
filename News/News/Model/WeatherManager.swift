//
//  WeatherManager.swift
//  News
//
//  Created by 陈一鸣 on 4/12/20.
//  Copyright © 2020 陈一鸣. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
}

struct WeatherManager{
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String, stateName: String) {
        let urlString = "\(Constants.weatherURL)\(cityName)"
        performRequest(with: urlString, cityName: cityName, stateName: stateName)
    }
    
    func performRequest(with urlString: String, cityName: String, stateName: String) {
        if let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            AF.request(url, method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let temp = json["main"]["temp"].doubleValue
                    let summary = json["weather"][0]["main"].stringValue
                    let weather = WeatherModel(summary: summary, cityName: cityName, stateName: stateName, temperature: temp)
                    self.delegate?.didUpdateWeather(self, weather: weather)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    
}
