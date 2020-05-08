//
//  TrendingViewController.swift
//  News
//
//  Created by 陈一鸣 on 4/11/20.
//  Copyright © 2020 陈一鸣. All rights reserved.
//

import UIKit
import Charts
import SwiftSpinner

class TrendingViewController: UIViewController {
    var trendingManager = TrendingManager()
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var noDataLabel: UILabel!
    var chartView: LineChartView!
    var trendingData: [ChartDataEntry] = []
    var trendingSearchKeyword = "Coronavirus"
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Trending")
        trendingManager.delegate = self
        trendingManager.fetchTrending(trendingSearchKeyword)
        searchTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // SwiftSpinner.show("Loading Trending Page..")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - TrendingManagerDelegate
extension TrendingViewController: TrendingManagerDelegate {
    func didUpdateTrending(_ trendingManager: TrendingManager, trending: [ChartDataEntry]) {
        self.trendingData = trending
        DispatchQueue.main.async {
            if let preChartView = self.chartView {
                preChartView.removeFromSuperview()
            }
            if let emptyLabel = self.noDataLabel {
                emptyLabel.removeFromSuperview()
            }
            self.chartView = LineChartView()
            self.chartView.frame = CGRect(x: 0, y: 325, width: self.view.bounds.width, height: 410)
            self.view.addSubview(self.chartView)
            let chartDataSet = LineChartDataSet(entries: self.trendingData, label: "Trending Chart for " + self.trendingSearchKeyword)
            chartDataSet.colors = [#colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1)]
            chartDataSet.circleRadius = 5
            chartDataSet.circleHoleRadius = 0
            chartDataSet.circleColors = [#colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1)]
            let chartData = LineChartData(dataSets: [chartDataSet])
            self.chartView.data = chartData
            // SwiftSpinner.hide()
        }
        
        
    }
}

//MARK: - UITextFieldDelegate
extension TrendingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something here"
            return false
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let keyword = searchTextField.text {
            self.trendingSearchKeyword = keyword
            trendingManager.fetchTrending(self.trendingSearchKeyword)
        }
    }
}
