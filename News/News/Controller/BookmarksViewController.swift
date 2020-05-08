//
//  BookmarksViewController.swift
//  News
//
//  Created by 陈一鸣 on 4/11/20.
//  Copyright © 2020 陈一鸣. All rights reserved.
//

import UIKit
import Kingfisher

class BookmarksViewController: UIViewController {
    @IBOutlet weak var noBookmarkLabel: UILabel!
    @IBOutlet weak var bookmarkCollectionView: UICollectionView!
    var bookmarkManager = BookmarkManager()
    var bookmarkedNews: [NewsModel] = []
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Bookmarks")
        
        bookmarkManager.delegate = self
        bookmarkManager.getBookmarks()
        
        bookmarkCollectionView.dataSource = self
        bookmarkCollectionView.register(UINib(nibName: "BookmarkCell", bundle: nil), forCellWithReuseIdentifier: "bookmarkedNewsCard")
        bookmarkCollectionView.delegate = self
        let numberOfItemPerRow: CGFloat = 2
        let lineSpacing: CGFloat = 10
        let innerItemSpacing: CGFloat = 10
        let width = (bookmarkCollectionView.frame.width - (numberOfItemPerRow - 1) * innerItemSpacing) / numberOfItemPerRow
        let height = width + 80
        collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.itemSize = CGSize(width: width, height: height)
        collectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
        collectionViewFlowLayout.scrollDirection = .vertical
        collectionViewFlowLayout.minimumLineSpacing = lineSpacing
        collectionViewFlowLayout.minimumInteritemSpacing = innerItemSpacing
        
        bookmarkCollectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bookmarkManager.getBookmarks()
        bookmarkCollectionView.reloadData()
    }
    
}

//MARK: - BookmarkManagerDelegate
extension BookmarksViewController: BookmarkManagerDelegate {
    func didUpdateBookmark(_ bookmarkManager: BookmarkManager, bookmark: [BookmarkModel]) {
        if let news = Constants.defaultStand.object(forKey: "csci571-news") as? Data {
            let decoder = JSONDecoder()
            if let bkNews = try? decoder.decode([NewsModel].self, from: news){
                self.bookmarkedNews = bkNews
            }
        }
        if self.bookmarkedNews.count != 0 {
            self.noBookmarkLabel.text = ""
        }
        else {
            self.noBookmarkLabel.text = "No bookmarks added."
        }
    }
}

//MARK: - UICollectionViewDataSource
extension BookmarksViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bookmarkedNews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookmarkedNewsCard", for: indexPath) as! BookmarkCell
        cell.bookmarkedNewsTitle.text = bookmarkedNews[indexPath.row].title
        cell.bookmarkedNewsTime.text = bookmarkedNews[indexPath.row].time
        let sectionName = bookmarkedNews[indexPath.row].section
        cell.bookmarkedNewsSection.text = "| \(sectionName)"
        let image = bookmarkedNews[indexPath.row].urlToImg
        if image == "NOIMAGE" {
            cell.bookmarkedNewsImage.image = UIImage(named: "default-guardian")
        }
        else {
             cell.bookmarkedNewsImage.kf.setImage(with: URL(string: image)!)
        }
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        cell.layer.borderWidth = 1
        cell.news = bookmarkedNews[indexPath.row]
        cell.delegate = self
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension BookmarksViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailedNews = bookmarkedNews[indexPath.row]
        self.performSegue(withIdentifier: "goToDetailedNewsFromBookmark", sender: detailedNews)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetailedNewsFromBookmark" {
            let destinationVC = segue.destination as! DetailedNewsViewController
            let detailedNews = sender as? NewsModel
            destinationVC.article_id = detailedNews?.id
            destinationVC.detailedNews = detailedNews
        }
    }
}

//MARK: - BookmarkCellDelegate
extension BookmarksViewController: BookmarkCellDelegate {
    func didDelete() {
        self.bookmarkManager.getBookmarks()
        self.bookmarkCollectionView.reloadData()
    }
    func showRemoveToast() {
        self.view.makeToast("Article Removed from Bookmarks.")
    }
}
