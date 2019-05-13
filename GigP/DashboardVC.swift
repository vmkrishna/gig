//
//  FirstViewController.swift
//  GigP
//
//  Created by Krishna Vemulapali on 2019-04-20.
//  Copyright © 2019 Krishna Vemulapali. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCards


class DashboardVC: UIViewController {
    @IBOutlet var dashBoardTab: UITabBarItem!
    
    @IBOutlet var yearlyHST: UILabel!
    @IBOutlet var yearToDateHours: UILabel!
    @IBOutlet var yearToDateExpenses: UILabel!
    @IBOutlet var yearlyEarnings: UILabel!
    @IBOutlet weak var monthlyView: UICollectionView!
    @IBOutlet var yearlyDashBoardView: UIView!
    
    var months = ["Jan", "Feb", "March", "April", "May", "June", "July", "Aug", "Sep"]
    var currentMonth = Calendar.current.component(.month, from: Date())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monthlyView.register(MonthlyCellCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        
        if let formattedHYearlyEarnings = formatter.string(from: appDelegate.model.getYearlyEarning() as NSNumber) {
            yearlyEarnings.text = formattedHYearlyEarnings
        }
        
        if let formattedHYearlyHST = formatter.string(from: appDelegate.model.getYearlyHST() as NSNumber) {
            yearlyHST.text = formattedHYearlyHST
        }
        
        yearToDateHours.text = "" + String(appDelegate.model.getYearlyHours())
        yearToDateExpenses.text = "$"
        
        monthlyView.reloadData()
    }
 
    
   
    
    
}

extension DashboardVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //MARK: ToDo , hack to deal with dates roll over have to fix this
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Month Dashboard", for: indexPath) as! MonthlyCellCollectionViewCell
        var monthEnd = currentMonth
        var monthStart = currentMonth - 1
        
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        
        if (cell.monthlyEarnings == nil) {
            cell.monthlyEarnings = UILabel()
        }
        cell.backgroundColor = UIColor(red:0.77, green:0.90, blue:0.90, alpha:1.0)
        
        monthEnd = currentMonth + 1 - indexPath.section
        monthStart = monthEnd - 1
      
        let stringDateStart = "2019-" + String(monthStart) + "-01"
        let stringDateEnd = "2019-" + String(monthEnd) + "-01"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateEnd = dateFormatter.date(from: stringDateEnd)!
        let dateStart = dateFormatter.date(from: stringDateStart)!
        
        if let earnings = formatter.string(from: appDelegate.model.getEarningByMonth( monthStart: dateStart,  monthEnd: dateEnd) as NSNumber) {
            cell.monthlyEarnings.text = earnings
        }
        let hours = appDelegate.model.getHoursByMonth( monthStart: dateStart,  monthEnd: dateEnd)
        if let hst = formatter.string(from: appDelegate.model.getHSTByMonth( monthStart: dateStart,  monthEnd: dateEnd) as NSNumber) {
            cell.monthlyHST.text = hst
        }
       
        cell.month.text = months[monthStart - 1]
        cell.monthlyHours.text = String(hours)
        cell.monthlyExpense.text = ""
       
        
        return cell
    }
}

extension DashboardVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //This can be used for delete items and other actions on the collection view
    }
}


    

