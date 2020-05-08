//
//  DetailedNewsViewController.swift
//  News
//
//  Created by 陈一鸣 on 4/14/20.
//  Copyright © 2020 陈一鸣. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner
import Toast_Swift
import Kingfisher

class DetailedNewsViewController: UIViewController {
    
    var article_id: String?
    @IBOutlet weak var detailedNewsNavigation: UINavigationItem!
    @IBOutlet weak var detailedNewsImage: UIImageView!
    @IBOutlet weak var detailedNewsTitle: UILabel!
    @IBOutlet weak var detailedNewsSection: UILabel!
    @IBOutlet weak var detailedNewsTime: UILabel!
    @IBOutlet weak var detailedNewsBody: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var twitterShareButton: UIButton!
    
    var detailedNewsManager = DetailedNewsManager()
    var newsUrl: String?
    var detailedNews: NewsModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        detailedNewsManager.delegate = self
        detailedNewsManager.fetchDetailedNews(article_id!)
        SwiftSpinner.show("Loading Detailed Article..")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var flag: Bool = false
        if let bookmarkedNews = Constants.defaultStand.object(forKey: "csci571-news") as? Data {
            let decoder = JSONDecoder()
            if let bookmarkedNews = try? decoder.decode([NewsModel].self, from: bookmarkedNews){
                for eachNews in bookmarkedNews {
                    if eachNews.id == detailedNews.id {
                        flag = true
                        break;
                    }
                }
            }
        }
        if flag == true {
            bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        }
        else {
            bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        }
    }
    @IBAction func fullArticlePressed(_ sender: UIButton) {
        if let newsUrl = newsUrl {
            let openUrl = newsUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            if let url = NSURL(string: openUrl)  {
                UIApplication.shared.open(url as URL)
            }
        }
    }
    
    @IBAction func bookmarkPressed(_ sender: UIButton) {
        let curImg = sender.currentImage
        if curImg == UIImage(systemName: "bookmark") {
            sender.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            
            var newsArray: [NewsModel] = []
            if let bookmarkedNews = Constants.defaultStand.object(forKey: "csci571-news") as? Data {
                let decoder = JSONDecoder()
                if let bookmarkedNews = try? decoder.decode([NewsModel].self, from: bookmarkedNews){
                    newsArray = bookmarkedNews
                }
            }
            newsArray.append(self.detailedNews)
            let encoder = JSONEncoder()
            let encoded = try? encoder.encode(newsArray)
            Constants.defaultStand.set(encoded, forKey: "csci571-news")
            self.view.makeToast("Article Bookmarked. Check out the Bookmarks tab to view.")
        }
        else if curImg == UIImage(systemName: "bookmark.fill") {
            sender.setImage(UIImage(systemName: "bookmark"), for: .normal)
            var newsArray: [NewsModel] = []
            if let bookmarkedNews = Constants.defaultStand.object(forKey: "csci571-news") as? Data {
                let decoder = JSONDecoder()
                if let bookmarkedNews = try? decoder.decode([NewsModel].self, from: bookmarkedNews){
                    for eachNews in bookmarkedNews {
                        if eachNews.id != detailedNews.id {
                            newsArray.append(eachNews)
                        }
                    }
                }
            }
            let encoder = JSONEncoder()
            let encoded = try? encoder.encode(newsArray)
            Constants.defaultStand.set(encoded, forKey: "csci571-news")
            self.view.makeToast("Article Removed from Bookmarks.")
        }
    }
    @IBAction func twitterSharePressed(_ sender: UIButton) {
        let shareString = "https://twitter.com/intent/tweet?text=Check Out this Article!&url=\(newsUrl!)&hashtags=CSCI_571_NewsApp"
        let shareURL = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        if let url = NSURL(string: shareURL)  {
            UIApplication.shared.open(url as URL)
        }
    }
}

//MARK: - DetailedNewsManagerDelegate
extension DetailedNewsViewController: DetailedNewsManagerDelegate {
    func didUpdateNews(_ detailedNewsManager: DetailedNewsManager, detailedNews: DetailedNewsModel) {
        DispatchQueue.main.async {
            self.detailedNewsNavigation.title = detailedNews.title
            self.detailedNewsTitle.text = detailedNews.title
            self.detailedNewsSection.text = detailedNews.section
            self.detailedNewsTime.text = detailedNews.time
            let body = "<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: 18.0\">\(detailedNews.description)</span>"
            guard let data = body.data(using: String.Encoding.unicode) else { return }
            try? self.detailedNewsBody.attributedText = NSAttributedString(data: data, options: [.documentType:NSAttributedString.DocumentType.html], documentAttributes: nil)
            if detailedNews.urlToImg == "NOIMAGE" {
                self.detailedNewsImage.image = UIImage(named: "default-guardian")
            }
            else {
                self.detailedNewsImage.kf.setImage(with: URL(string: detailedNews.urlToImg))
            }
            self.newsUrl = detailedNews.url
            SwiftSpinner.hide()
        }
    }
    
    
}
