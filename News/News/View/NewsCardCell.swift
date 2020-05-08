//
//  NewsCardCell.swift
//  News
//
//  Created by 陈一鸣 on 4/12/20.
//  Copyright © 2020 陈一鸣. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol NewsCardCellDelegate {
    func showToast(_ type: Bool)
}

class NewsCardCell: UITableViewCell {
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var newsCardView: UIView!
    @IBOutlet weak var cardView: UIView!
    
    var news = NewsModel(id: "", title: "", url: "", urlToImg: "", section: "", time: "", timeDiff: "")
    var delegate: NewsCardCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        // Initialization code
        newsImage.layer.cornerRadius = 10
        newsCardView.layer.cornerRadius = 10
        newsCardView.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        newsCardView.layer.borderWidth = 1
        
        let interaction = UIContextMenuInteraction(delegate: self)
        cardView.addInteraction(interaction)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
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
            newsArray.append(self.news)
            let encoder = JSONEncoder()
            let encoded = try? encoder.encode(newsArray)
            Constants.defaultStand.set(encoded, forKey: "csci571-news")
            self.delegate?.showToast(true)
        }
        else if curImg == UIImage(systemName: "bookmark.fill") {
            sender.setImage(UIImage(systemName: "bookmark"), for: .normal)
            var newsArray: [NewsModel] = []
            if let bookmarkedNews = Constants.defaultStand.object(forKey: "csci571-news") as? Data {
                let decoder = JSONDecoder()
                if let bookmarkedNews = try? decoder.decode([NewsModel].self, from: bookmarkedNews){
                    for eachNews in bookmarkedNews {
                        if eachNews.id != news.id {
                            newsArray.append(eachNews)
                        }
                    }
                }
            }
            let encoder = JSONEncoder()
            let encoded = try? encoder.encode(newsArray)
            Constants.defaultStand.set(encoded, forKey: "csci571-news")
            self.delegate?.showToast(false)
        }
    }
    
}

//MARK: - UIContextMenuInteractionDelegate
extension NewsCardCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            let share = UIAction(title: "Share with Twitter", image: UIImage(named: "twitter")) { action in
                let shareString = "https://twitter.com/intent/tweet?text=Check Out this Article!&url=\(self.news.url)&hashtags=CSCI_571_NewsApp"
                let shareURL = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                if let url = NSURL(string: shareURL)  {
                    UIApplication.shared.open(url as URL)
                }
            }
            var flag: Bool = false
            if let bookmarkedNews = Constants.defaultStand.object(forKey: "csci571-news") as? Data {
                let decoder = JSONDecoder()
                if let bookmarkedNews = try? decoder.decode([NewsModel].self, from: bookmarkedNews){
                    for eachNews in bookmarkedNews {
                        if eachNews.id == self.news.id {
                            flag = true
                            break;
                        }
                    }
                }
            }
            var rename: UIAction?
            if flag == true {
                rename = UIAction(title: "Bookmark", image: UIImage(systemName: "bookmark.fill")) { action in
                    var newsArray: [NewsModel] = []
                    if let bookmarkedNews = Constants.defaultStand.object(forKey: "csci571-news") as? Data {
                        let decoder = JSONDecoder()
                        if let bookmarkedNews = try? decoder.decode([NewsModel].self, from: bookmarkedNews){
                            for eachNews in bookmarkedNews {
                                if eachNews.id != self.news.id {
                                    newsArray.append(eachNews)
                                }
                            }
                        }
                    }
                    let encoder = JSONEncoder()
                    let encoded = try? encoder.encode(newsArray)
                    Constants.defaultStand.set(encoded, forKey: "csci571-news")
                    self.bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
                    self.delegate?.showToast(false)
                }
            }
            else {
                rename = UIAction(title: "Bookmark", image: UIImage(systemName: "bookmark")) { action in
                    var newsArray: [NewsModel] = []
                    if let bookmarkedNews = Constants.defaultStand.object(forKey: "csci571-news") as? Data {
                        let decoder = JSONDecoder()
                        if let bookmarkedNews = try? decoder.decode([NewsModel].self, from: bookmarkedNews){
                            newsArray = bookmarkedNews
                        }
                    }
                    newsArray.append(self.news)
                    let encoder = JSONEncoder()
                    let encoded = try? encoder.encode(newsArray)
                    Constants.defaultStand.set(encoded, forKey: "csci571-news")
                    self.bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
                    self.delegate?.showToast(true)
                }
            }
            return UIMenu(title: "Menu", children: [share, rename!])
        }
    }
}
