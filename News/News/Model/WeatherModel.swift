//
//  WeatherModel.swift
//  News
//
//  Created by 陈一鸣 on 4/12/20.
//  Copyright © 2020 陈一鸣. All rights reserved.
//

import Foundation

struct WeatherModel {
    let summary: String
    let cityName: String
    let stateName: String
    let temperature: Double
    var weatherImage: String{
        switch summary {
        case "Clouds":
            return "cloudy_weather"
        case "Clear":
            return "clear_weather"
        case "Snow":
            return "snowy_weather"
        case "Rain":
            return "rainy_weather"
        case "Thunderstorm":
            return "thunder_weather"
        default:
            return "sunny_weather"
        }
    }
    var temperatureString: String {
        let tmp = String(format: "%.1f", temperature)
        return "\(tmp)°C"
    }
    
    init(){
        summary = ""
        cityName = ""
        stateName = ""
        temperature = 16.6
    }
    
    init(summary: String, cityName: String, stateName: String, temperature: Double){
        self.summary = summary
        self.cityName = cityName
        self.stateName = stateName
        self.temperature = temperature
    }
}
