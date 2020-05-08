//
//  SearchResultsViewController.swift
//  News
//
//  Created by 陈一鸣 on 4/17/20.
//  Copyright © 2020 陈一鸣. All rights reserved.
//

import UIKit
import SwiftSpinner
import Kingfisher

class SearchResultsViewController: UIViewController {
    
    @IBOutlet weak var searchResultsTableView: UITableView!
    var searchKeyword: String?
    var searchResultsManager = SearchResultsManager()
    var searchResults: [NewsModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultsManager.delegate = self
        searchResultsManager.fetchResultNews(searchKeyword!)
        searchResultsTableView.dataSource = self
        searchResultsTableView.register(UINib(nibName: "NewsCardCell", bundle: nil), forCellReuseIdentifier: "newsCard")
        searchResultsTableView.delegate = self
        SwiftSpinner.show("Loading Search Results..")
        searchResultsTableView.separatorStyle = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchResultsTableView.reloadData()
    }
    
    @objc func refreshData() {
        searchResultsManager.fetchResultNews(searchKeyword!)
    }
}

//MARK: - SearchResultsManagerDelegate
extension SearchResultsViewController: SearchResultsManagerDelegate {
    func didUpdateSearchResult(_ searchResultsManager: SearchResultsManager, news: [NewsModel]) {
        self.searchResults = news
        SwiftSpinner.hide()
        self.searchResultsTableView.reloadData()
    }
    
    
}

//MARK: - UITableViewDataSource
extension SearchResultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCard", for: indexPath) as! NewsCardCell
        cell.titleLabel.text = searchResults[indexPath.row].title
        cell.timeLabel.text = searchResults[indexPath.row].timeDiff
        let sectionName = searchResults[indexPath.row].section
        cell.sectionLabel.text = "| \(sectionName)"
        let image = searchResults[indexPath.row].urlToImg
        if image == "NOIMAGE" {
            cell.newsImage.image = UIImage(named: "default-guardian")
        }
        else {
             cell.newsImage.kf.setImage(with: URL(string: image)!)
        }
        cell.news = NewsModel(id: searchResults[indexPath.row].id,
                              title: searchResults[indexPath.row].title,
                              url: searchResults[indexPath.row].url,
                              urlToImg: searchResults[indexPath.row].urlToImg,
                              section: searchResults[indexPath.row].section,
                              time: searchResults[indexPath.row].time,
                              timeDiff: searchResults[indexPath.row].timeDiff)
        var flag: Bool = false
        if let bookmarkedNews = Constants.defaultStand.object(forKey: "csci571-news") as? Data {
            let decoder = JSONDecoder()
            if let bookmarkedNews = try? decoder.decode([NewsModel].self, from: bookmarkedNews){
                for eachNews in bookmarkedNews {
                    if eachNews.id == searchResults[indexPath.row].id {
                        flag = true
                        break;
                    }
                }
            }
        }
        if flag == true {
            cell.bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        }
        else {
            cell.bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        }
        cell.delegate = self
        return cell
    }
    
    
}

//MARK: - UITableViewDelegate
extension SearchResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == searchResultsTableView {
            let news = searchResults[indexPath.row]
            self.performSegue(withIdentifier: "goToDetailedNewsFromSearch", sender: news)
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetailedNewsFromSearch" {
            let destinationVC = segue.destination as! DetailedNewsViewController
            let detailedNews = sender as? NewsModel
            destinationVC.article_id = detailedNews?.id
            destinationVC.detailedNews = detailedNews
        }
    }
}

//MARK: - NewsCardCellDelegate
extension SearchResultsViewController: NewsCardCellDelegate {
    func showToast(_ type: Bool) {
        if type {
            self.view.makeToast("Article Bookmarked. Check out the Bookmarks tab to view.")
        } else {
            self.view.makeToast("Article Removed from Bookmarks.")
        }
    }
}
