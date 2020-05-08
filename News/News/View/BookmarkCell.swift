//
//  BookmarkCell.swift
//  News
//
//  Created by 陈一鸣 on 4/15/20.
//  Copyright © 2020 陈一鸣. All rights reserved.
//

import UIKit

protocol BookmarkCellDelegate {
    func didDelete()
    func showRemoveToast()
}

class BookmarkCell: UICollectionViewCell {
    @IBOutlet weak var bookmarkedNewsImage: UIImageView!
    @IBOutlet weak var bookmarkedNewsTitle: UILabel!
    
    @IBOutlet weak var bookmarkedNewsTime: UILabel!
    
    @IBOutlet weak var bookmarkedNewsSection: UILabel!
    @IBOutlet weak var bookmarkedNewsBookmark: UIButton!
    
    @IBOutlet weak var bookmarkView: UIView!
    var news: NewsModel!
    var delegate: BookmarkCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        bookmarkedNewsBookmark.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        let maskPath = UIBezierPath(roundedRect: bookmarkedNewsImage.bounds, byRoundingCorners: [UIRectCorner.topRight, UIRectCorner.topLeft], cornerRadii: CGSize(width: 5, height: 5))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bookmarkedNewsImage.bounds
        maskLayer.path = maskPath.cgPath
        bookmarkedNewsImage.layer.mask = maskLayer
        
        let interaction = UIContextMenuInteraction(delegate: self)
        bookmarkView.addInteraction(interaction)
    }
    @IBAction func bookmarkedNewsBookmarkPressed(_ sender: UIButton) {
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
        self.delegate?.didDelete()
        self.delegate?.showRemoveToast()
    }
    
}

//MARK: - UIContextMenuInteractionDelegate
extension BookmarkCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            let share = UIAction(title: "Share with Twitter", image: UIImage(named: "twitter")) { action in
                let shareString = "https://twitter.com/intent/tweet?text=Check Out this Article!&url=\(self.news.url)&hashtags=CSCI_571_NewsApp"
                let shareURL = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                if let url = NSURL(string: shareURL)  {
                    UIApplication.shared.open(url as URL)
                }
            }
            let rename = UIAction(title: "Bookmark", image: UIImage(systemName: "bookmark.fill")) { action in
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
                self.delegate?.didDelete()
                self.delegate?.showRemoveToast()
            }
            
            return UIMenu(title: "Menu", children: [share, rename])
        }
    }
}
