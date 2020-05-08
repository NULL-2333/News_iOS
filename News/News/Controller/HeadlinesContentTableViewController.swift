//
//  HeadlinesContentTableViewController.swift
//  News
//
//  Created by 陈一鸣 on 4/16/20.
//  Copyright © 2020 陈一鸣. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Toast_Swift
import SwiftSpinner
import Kingfisher

protocol HeadlinesContentTableViewControllerDelegate {
    func openDeatiledNews(news: NewsModel)
    func showSpinner(content: String)
    func showToast(_ flag: Bool)
}

class HeadlinesContentTableViewController: UITableViewController {

    var indiactorInfo: IndicatorInfo = "View"
    var sectionNewsManager = SectionNewsManager()
    var sectionNews: [NewsModel] = []
    var delegate: HeadlinesContentTableViewControllerDelegate?
    var refreshControlInHeadlines = UIRefreshControl()
    
    init(style: UITableView.Style, indiactorInfo: IndicatorInfo) {
        self.indiactorInfo = indiactorInfo
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "NewsCardCell", bundle: nil), forCellReuseIdentifier: "newsCard")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        // self.tableView.autoresizingMask = UIViewAutores
        sectionNewsManager.delegate = self
        sectionNewsManager.fetchNews(sectionName: indiactorInfo.title!.lowercased())
        
        refreshControlInHeadlines.addTarget(self, action: #selector(HeadlinesContentTableViewController.refreshData), for: .valueChanged)
        self.tableView.addSubview(refreshControlInHeadlines)
        self.tableView.separatorStyle = .none
    }
    
    @objc func refreshData() {
        sectionNewsManager.fetchNews(sectionName: indiactorInfo.title!.lowercased())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.delegate?.showSpinner(content: indiactorInfo.title ?? "DEFAULT")
        // SwiftSpinner.show("Loading \(indiactorInfo.title ?? "DEFAULT") Headlines..")
        sectionNewsManager.fetchNews(sectionName: indiactorInfo.title!.lowercased())
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionNews.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCard", for: indexPath) as! NewsCardCell
        cell.titleLabel.text = sectionNews[indexPath.row].title
        cell.timeLabel.text = sectionNews[indexPath.row].timeDiff
        let sectionName = sectionNews[indexPath.row].section
        cell.sectionLabel.text = "| \(sectionName)"
        let image = sectionNews[indexPath.row].urlToImg
        if image == "NOIMAGE" {
            cell.newsImage.image = UIImage(named: "default-guardian")
        }
        else {
             cell.newsImage.kf.setImage(with: URL(string: image)!)
        }
        cell.news = NewsModel(id: sectionNews[indexPath.row].id,
                              title: sectionNews[indexPath.row].title,
                              url: sectionNews[indexPath.row].url,
                              urlToImg: sectionNews[indexPath.row].urlToImg,
                              section: sectionNews[indexPath.row].section,
                              time: sectionNews[indexPath.row].time,
                              timeDiff: sectionNews[indexPath.row].timeDiff)
        var flag: Bool = false
        if let bookmarkedNews = Constants.defaultStand.object(forKey: "csci571-news") as? Data {
            let decoder = JSONDecoder()
            if let bookmarkedNews = try? decoder.decode([NewsModel].self, from: bookmarkedNews){
                for eachNews in bookmarkedNews {
                    if eachNews.id == sectionNews[indexPath.row].id {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.openDeatiledNews(news: sectionNews[indexPath.row])
    }
    
    
}

//MARK: - IndicatorInfoProvider
extension HeadlinesContentTableViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return self.indiactorInfo
    }
}

//MARK: - SectionNewsManagerDelegate
extension HeadlinesContentTableViewController: SectionNewsManagerDelegate {
    func didUpdateSectionNews(_ sectionNewsManager: SectionNewsManager, news: [NewsModel]) {
        self.sectionNews = news
        SwiftSpinner.hide()
        self.tableView.reloadData()
        self.refreshControlInHeadlines.endRefreshing()
    }
}

//MARK: - NewsCardCellDelegate
extension HeadlinesContentTableViewController: NewsCardCellDelegate {
    func showToast(_ type: Bool) {
        self.delegate?.showToast(type)
    }
}

