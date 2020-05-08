//
//  FirstViewController.swift
//  News
//
//  Created by 陈一鸣 on 4/10/20.
//  Copyright © 2020 陈一鸣. All rights reserved.
//

import UIKit
import CoreLocation
import Kingfisher
import SwiftSpinner
import SwiftyJSON

class HomeViewController: UIViewController {
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var stateNameLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var newsCardsTableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var searchChoicesTableView: UITableView!
    
    @IBOutlet weak var searchChoicesView: UIView!
    
    var locationManager = CLLocationManager()
    var weatherManager = WeatherManager()
    var newsManager = NewsManager()
    var searchChoiceManager = SearchChoiceManager()
    var news: [NewsModel] = []
    
    var refreshControl = UIRefreshControl()
    var searchController: UISearchController!
    var searchKeyword: String?
    var searchChoices: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("Home")
        weatherImage.layer.cornerRadius = 10
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        weatherManager.delegate = self
        
        newsManager.delegate = self
//        newsManager.fetchNews()
        
        
        newsCardsTableView.dataSource = self
        newsCardsTableView.register(UINib(nibName: "NewsCardCell", bundle: nil), forCellReuseIdentifier: "newsCard")
        newsCardsTableView.delegate = self
        
        searchChoicesView.isHidden = true
        searchChoicesTableView.dataSource = self
        searchChoicesTableView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(HomeViewController.refreshData), for: .valueChanged)
        newsCardsTableView.addSubview(refreshControl)
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchBar.placeholder = "Enter Keyword.."
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.searchController = self.searchController
        
        navigationController?.navigationBar.sizeToFit()
        
        searchChoiceManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if searchChoicesView.isHidden{
            SwiftSpinner.show("Loading Home Page..")
        }
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        newsManager.fetchNews()
        newsCardsTableView.reloadData()
        // self.searchChoicesView.isHidden = true
        // searchController.searchBar.text = searchKeyword
    }
    
    @objc func refreshData() {
        newsManager.fetchNews()
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

}

//MARK: - WeatherManagerDelegate
extension HomeViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.cityNameLabel.text = weather.cityName
            self.stateNameLabel.text = Constants.stateDict[weather.stateName];
            self.tempLabel.text = weather.temperatureString
            self.weatherLabel.text = weather.summary
            self.weatherImage.image = UIImage(named: weather.weatherImage)
        }
    }
}

//MARK: - CLLocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            let geocoder = CLGeocoder()
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                        completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    let cityName = firstLocation?.subAdministrativeArea!
                    let stateName = firstLocation?.administrativeArea!
                    self.weatherManager.fetchWeather(cityName: cityName!, stateName: stateName!)
                }
                else {
                    self.weatherManager.fetchWeather(cityName: "Los Angeles", stateName: "CA")
                    print("Cannot get location")
                }
            })
        }
        else {
            self.weatherManager.fetchWeather(cityName: "Los Angeles", stateName: "CA")
            print("Cannot get location")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("!!!!!!!\(error)")
    }
}

//MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == newsCardsTableView{
            return news.count
        }
        if tableView == searchChoicesTableView {
            return searchChoices.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == newsCardsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsCard", for: indexPath) as! NewsCardCell
            cell.titleLabel.text = news[indexPath.row].title
            cell.timeLabel.text = news[indexPath.row].timeDiff
            let sectionName = news[indexPath.row].section
            cell.sectionLabel.text = "| \(sectionName)"
            let image = news[indexPath.row].urlToImg
            if image == "NOIMAGE" {
                cell.newsImage.image = UIImage(named: "default-guardian")
            }
            else {
                 cell.newsImage.kf.setImage(with: URL(string: image)!)
            }
            cell.news = NewsModel(id: news[indexPath.row].id,
                                  title: news[indexPath.row].title,
                                  url: news[indexPath.row].url,
                                  urlToImg: news[indexPath.row].urlToImg,
                                  section: news[indexPath.row].section,
                                  time: news[indexPath.row].time,
                                  timeDiff: news[indexPath.row].timeDiff)
            var flag: Bool = false
            if let bookmarkedNews = Constants.defaultStand.object(forKey: "csci571-news") as? Data {
                let decoder = JSONDecoder()
                if let bookmarkedNews = try? decoder.decode([NewsModel].self, from: bookmarkedNews){
                    for eachNews in bookmarkedNews {
                        if eachNews.id == news[indexPath.row].id {
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
        if tableView == searchChoicesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchChoiceCellOfHome", for: indexPath)
            cell.textLabel?.text = searchChoices[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
}

//MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == newsCardsTableView {
            let detailedNews = news[indexPath.row]
            self.performSegue(withIdentifier: "goToDetailedNews", sender: detailedNews)
        }
        else if tableView == searchChoicesTableView {
            let searchKeyword = searchChoices[indexPath.row]
            self.searchKeyword = searchKeyword
            self.performSegue(withIdentifier: "goToSearchResults", sender: searchKeyword)
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetailedNews" {
            let destinationVC = segue.destination as! DetailedNewsViewController
            let detailedNews = sender as? NewsModel
            destinationVC.article_id = detailedNews?.id
            destinationVC.detailedNews = detailedNews
        }
        else if segue.identifier == "goToSearchResults" {
            let destinationVC = segue.destination as! SearchResultsViewController
            let searchKeyword = sender as? String
            destinationVC.searchKeyword = searchKeyword
        }
    }
}

//MARK: - NewsManagerDelegate
extension HomeViewController: NewsManagerDelegate {
    func didUpdateNews(_ newsManager: NewsManager, news: [NewsModel]) {
        self.news = news
        SwiftSpinner.hide()
        self.newsCardsTableView.reloadData()
        self.refreshControl.endRefreshing()
    }
}

//MARK: - UISearchBarDelegate
extension HomeViewController: UISearchBarDelegate {
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
extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchKeyword = searchController.searchBar.text
        self.searchKeyword = searchKeyword
        DispatchQueue.main.asyncDeduped(target: self, after: 1.0) { [weak self] in
            self?.searchChoiceManager.fetchSearchChoices(searchKeyword!)
            self?.searchChoicesTableView.reloadData()
        }
        self.searchChoicesTableView.reloadData()
    }
}

//MARK: - SearchChoiceManagerDelegate
extension HomeViewController: SearchChoiceManagerDelegate {
    func didUpdateSearchChoice(_ searchChoiceManager: SearchChoiceManager, searchChoices: [String]) {
        self.searchChoices = searchChoices
        self.searchChoicesTableView.reloadData()
    }
    
    
}

//MARK: - NewsCardCellDelegate
extension HomeViewController: NewsCardCellDelegate {
    func showToast(_ type: Bool) {
        if type {
            self.view.makeToast("Article Bookmarked. Check out the Bookmarks tab to view.")
        } else {
            self.view.makeToast("Article Removed from Bookmarks.")
        }
    }
}
