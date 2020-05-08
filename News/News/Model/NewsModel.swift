//
//  NewsModel.swift
//  News
//
//  Created by 陈一鸣 on 4/13/20.
//  Copyright © 2020 陈一鸣. All rights reserved.
//

import Foundation

struct NewsModel: Codable{
    var id: String
    var title: String
    var url: String
    var urlToImg: String
    var section: String
    var time: String
    var timeDiff: String
}


