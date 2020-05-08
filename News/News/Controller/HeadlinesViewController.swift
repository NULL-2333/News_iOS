//
//  SecondViewController.swift
//  News
//
//  Created by 陈一鸣 on 4/10/20.
//  Copyright © 2020 陈一鸣. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftSpinner
import Toast_Swift

class HeadlinesViewController: ButtonBarPagerTabStripViewController {
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var headlinesScrollView: UIScrollView!
    @IBOutlet weak var searchChoicesView: UIView!
    @IBOutlet weak var searchChoicesTableView: UITableView!
    
    var searchController: UISearchController!
    var sectionNews: [NewsModel] = []
    var searchChoiceManager = SearchChoiceManager()
    var searchKeyword: String?
    var searchChoices: [String] = []
    let blueInstagramColor = UIColor(red: 37/255.0, green: 111/255.0, blue: 206/255.0, alpha: 1.0)
    override func viewDidLoad() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1)
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 17)
        settings.style.selectedBarHeight = 4.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .gray
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        settings.style.buttonBarHeight = 16.0

        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .gray
            newCell?.label.textColor = #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1)
        }
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("Headlines")
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchBar.placeholder = "Enter Keyword.."
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.searchController = self.searchController
        navigationController?.navigationBar.sizeToFit()
        searchChoiceManager.delegate = self
        
        self.searchChoicesView.isHidden = true
        searchChoicesTableView.dataSource = self
        searchChoicesTableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.sizeToFit()
        super.viewDidAppear(animated)
        self.searchChoicesView.isHidden = true
        // searchController.searchBar.text = self.searchKeyword
        
    }
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let sectionNames = ["WORLD", "BUSINESS", "POLITICS", "SPORT", "TECHNOLOGY", "SCIENCE"]
        var chidrenView: [UIViewController] = []
        for i in 0..<sectionNames.count {
            let childView = HeadlinesContentTableViewController(style: .plain, indiactorInfo: IndicatorInfo(title: sectionNames[i]))
            
            childView.delegate = self
            chidrenView.append(childView)
        }
        return chidrenView
    }
}

//MARK: - UISearchBarDelegate
extension HeadlinesViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchChoicesView.isHidden = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchChoicesView.isHidden = true
        self.searchChoices = []
        self.searchChoicesTableView.reloadData()
    }
}

//MARK: - UISearchResultsUpdating
extension HeadlinesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchKeyword = searchController.searchBar.text
        self.searchKeyword = searchKeyword
        DispatchQueue.main.asyncDeduped(target: self, after: 1.0) { [weak self] in
            self?.searchChoiceManager.fetchSearchChoices(searchKeyword!)
            self?.searchChoicesTableView.reloadData()
        }
    }
}

//MARK: - HeadlinesContentTableViewControllerDelegate
extension HeadlinesViewController: HeadlinesContentTableViewControllerDelegate {
    func showSpinner(content: String) {
        if self.searchChoicesView.isHidden{
            SwiftSpinner.show("Loading \(content) Headlines..")
        }
    }
    
    func openDeatiledNews(news: NewsModel) {
        self.performSegue(withIdentifier: "goToDetailedNewsFromHeadlines", sender: news)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetailedNewsFromHeadlines" {
            let destinationVC = segue.destination as! DetailedNewsViewController
            let detailedNews = sender as? NewsModel
            destinationVC.article_id = detailedNews?.id
            destinationVC.detailedNews = detailedNews
        }
        else if segue.identifier == "goToSearchResultsFromHeadlines" {
            let destinationVC = segue.destination as! SearchResultsViewController
            let searchKeyword = sender as? String
            destinationVC.searchKeyword = searchKeyword
        }
    }
    func showToast(_ flag: Bool) {
        if flag {
            self.view.makeToast("Article Bookmarked. Check out the Bookmarks tab to view.")
        } else {
            self.view.makeToast("Article Removed from Bookmarks.")
        }
    }
}

//MARK: - SearchChoiceManagerDelegate
extension HeadlinesViewController: SearchChoiceManagerDelegate {
    func didUpdateSearchChoice(_ searchChoiceManager: SearchChoiceManager, searchChoices: [String]) {
        self.searchChoices = searchChoices
        self.searchChoicesTableView.reloadData()
    }
}

//MARK: - UITableViewDataSource
extension HeadlinesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchChoicesTableView {
            return searchChoices.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == searchChoicesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchChoiceCellOfHeadlines", for: indexPath)
            cell.textLabel?.text = searchChoices[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
}

//MARK: - UITableViewDelegate
extension HeadlinesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == searchChoicesTableView {
            let searchKeyword = searchChoices[indexPath.row]
            self.performSegue(withIdentifier: "goToSearchResultsFromHeadlines", sender: searchKeyword)
        }
        
    }
}

//MARK: - NewsCardCellDelegate
//extension HeadlinesViewController: NewsCardCellDelegate {
//    func showToast(_ type: Bool) {
//        if type {
//            self.view.makeToast("Article Bookmarked. Check out the Bookmarks tab to view.")
//        } else {
//            self.view.makeToast("Article Removed from Bookmarks.")
//        }
//    }
//}

