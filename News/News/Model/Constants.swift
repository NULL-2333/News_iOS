//
//  Constants.swift
//  News
//
//  Created by 陈一鸣 on 4/15/20.
//  Copyright © 2020 陈一鸣. All rights reserved.
//

import Foundation

struct Constants {
    static let backendUrl = "http://newsios-env.eba-u7pswydx.us-west-1.elasticbeanstalk.com/"
    // static let backendUrl = "http://localhost:8081/"
    static let defaultStand = UserDefaults.standard
    static let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=b2ca01a385fc20ff9ead09381a0919e4&units=metric&q="
    static let topNewsUrl = "\(backendUrl)guardian/top"
    static let detailedNewsUrl = "\(backendUrl)guardian/article?id="
    static let trendingUrl = "\(backendUrl)guardian/trending?keyword="
    static let sectionNameUrl = "\(backendUrl)guardian?section="
    static let autoSuggestUrl = "https://api.cognitive.microsoft.com/bing/v7.0/suggestions?q="
    static let autoSuggestKey = "200f1c67ba3746ec99b1f8b184485852"
    static let searchUrl = "\(backendUrl)guardian/search?q="
    
    static let stateDict = ["AL": "Alabama", "AK": "Alaska", "AZ": "Arizona", "AR": "Arkansas",
                            "CA": "California", "CO": "Colorado", "CT": "Connecticut", "DE": "Delaware",
                            "FL": "Florida", "GA": "Georgia", "HI": "Hawaii", "ID": "Idaho",
                            "IL": "Illinois", "IN": "Indiana", "IA": "Iowa", "KS": "Kansas",
                            "KY": "Kentucky", "LA": "Lousiana", "ME": "Maine", "MD": "Maryland",
                            "MA": "Massachusetts", "MI": "Michigan", "MN": "Minnesota", "MS": "Mississippi",
                            "MO": "Missouri", "MT": "Montana", "NE": "Nebraska", "NV": "Nevada",
                            "NH": "New Hampshire", "NJ": "New Jersey", "NM": "New Mexico", "NY": "New York",
                            "NC": "North Carolina", "ND": "North Dakota", "OH": "Ohio", "OK": "Oklahoma",
                            "OR": "Oregon", "PA": "Pennsylvania", "RI": "Rhode Island", "SC": "South Carolina",
                            "SD": "South Dakota", "TN": "Tennessee", "TX": "Texas", "UT": "Utah",
                            "VT": "Vermont", "VA": "Virginia", "WA": "Washington", "WV": "West Virginia",
                            "WI": "Wisconsin", "WY": "Wyoming"]
}
