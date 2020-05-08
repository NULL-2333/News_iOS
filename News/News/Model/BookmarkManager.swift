//
//  BookmarkManager.swift
//  News
//
//  Created by 陈一鸣 on 4/15/20.
//  Copyright © 2020 陈一鸣. All rights reserved.
//

import Foundation

protocol BookmarkManagerDelegate {
    func didUpdateBookmark(_ bookmarkManager: BookmarkManager, bookmark: [BookmarkModel])
}

struct BookmarkManager {
    var delegate: BookmarkManagerDelegate?
    var bookmarkData: [BookmarkModel] = []
    func getBookmarks() {
        self.delegate?.didUpdateBookmark(self, bookmark: [])
    }
}

