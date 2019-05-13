//
//  SecondViewController.swift
//  GigP
//
//  Created by Krishna Vemulapali on 2019-04-20.
//  Copyright © 2019 Krishna Vemulapali. All rights reserved.
//

import UIKit
import CoreData
import VACalendar
import BottomPopup

class WorkItemViewController: UIViewController {
   
    
    @IBOutlet var clockIt: UITabBarItem!
    
    @IBOutlet weak var dailyItemsTableView: UITableView!
    var calendarView: VACalendarView!
    
    let defaultCalendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        calendar.timeZone = TimeZone.current
        return calendar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildAndAddCalView()
        dailyItemsTableView.dataSource = self
        self.dailyItemsTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.dailyItemsTableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if calendarView.frame == .zero {
            calendarView.frame = CGRect(
                x: 0,
                y: weekDaysView.frame.maxY,
                width: view.frame.width,
                height: view.frame.height * 0.4
            )
            calendarView.setup()
            //Setup dots days when we have items present
            setupCalMarkers(month:0)
        }
        self.dailyItemsTableView.reloadData()
        
    }
    
    @IBOutlet weak var monthHeaderView: VAMonthHeaderView!{
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "LLLL"
            
            let appereance = VAMonthHeaderViewAppearance(
                previousButtonImage: #imageLiteral(resourceName: "previous"),
                nextButtonImage: #imageLiteral(resourceName: "next"),
                dateFormatter: dateFormatter
            )
            monthHeaderView.delegate = self
            monthHeaderView.appearance = appereance
        }
    }
    
    @IBOutlet weak var weekDaysView: VAWeekDaysView! {
        didSet {
            let appereance = VAWeekDaysViewAppearance(symbolsType: .veryShort, calendar: defaultCalendar)
            weekDaysView.appearance = appereance
        }
    }
    
    /** Get current date so that we can set things up right and mark the cal as worked
     */
    @IBAction func addWorkItem(_ sender: Any) {
        print(calendarView.startDate)
        //Bring up the item detials view
        let showItemStoryboard = UIStoryboard(name: "NewWorkItem", bundle: nil)
        let newWorkItemVC = (showItemStoryboard.instantiateViewController(withIdentifier: "NewWorkItem") as? AddItemViewController)!
        
        //Let the view know which date the workItem is for
        newWorkItemVC.workItemDate = calendarView.startDate
        //To know if an Add was done by the user. Getting data back from the loaded view
        //Good way of moving data between VCs
        newWorkItemVC.delegate = self
        present(newWorkItemVC, animated: true, completion: nil)
    }
    
   
    func buildAndAddCalView() {
        let calendar = VACalendar(calendar: defaultCalendar)
        calendarView = VACalendarView(frame: .zero, calendar: calendar)
        calendarView.showDaysOut = true
        calendarView.selectionStyle = .single
        calendarView.monthDelegate = monthHeaderView
        calendarView.dayViewAppearanceDelegate = self
        
        calendarView.calendarDelegate = self
        calendarView.scrollDirection = .horizontal
        view.addSubview(calendarView)
    }
    
    func setupCalMarkers(month: Int) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        var monthStart = calendarView.startDate.startOfMonth()
        var monthEnd = calendarView.startDate.endOfMonth()
        
        if (month != 0) {
            monthStart = addTimeToDate(days: 0, months: month, from: calendarView.startDate.startOfMonth())
            monthEnd = addTimeToDate(days: 0, months: month, from: calendarView.startDate.endOfMonth())
        }
        let daysWorked =  appDelegate.model.getDaysWorked(monthStart: monthStart, monthEnd: monthEnd)
        
        for day in daysWorked {
            calendarView.setSupplementaries([
                     (day, [VADaySupplementary.bottomDots([UIColor(red:0.77, green:0.90, blue:0.90, alpha:1.0)])]),
                        ])
        }
    }
   
    func addTimeToDate(days: Int, months: Int, from: Date) -> Date {
      
        var dateComponent = DateComponents()
        
        dateComponent.month = months
        dateComponent.day = days
        dateComponent.year = 0
        
        let newDate: Date = Calendar.current.date(byAdding: dateComponent, to: from)!
        
        return newDate
    }
}



//MARK: Cal delegates
extension WorkItemViewController: VAMonthHeaderViewDelegate {

    //MARK: ToDo: Dots won't get up properly when we move between months, need to
    // setup markers properly with dates
    func didTapNextMonth() {
        calendarView.nextMonth()
        setupCalMarkers(month: 1)
        calendarView.startDate = addTimeToDate(days: 0, months: 1, from: calendarView.startDate)
        self.dailyItemsTableView.reloadData()
    }

    func didTapPreviousMonth() {
        calendarView.previousMonth()
        setupCalMarkers(month: -1)
        calendarView.startDate = addTimeToDate(days: 0, months: -1, from: calendarView.startDate)
        
        self.dailyItemsTableView.reloadData()
    }
    
    //MARK: Adding moving through swipe

}




extension WorkItemViewController: VACalendarViewDelegate {
    
    func selectedDate(_ date: Date) {
        let calendar = NSCalendar.current
        let selectedDate = calendar.startOfDay(for: date)
        calendarView.startDate = selectedDate
        self.dailyItemsTableView.reloadData()
    }
    
}



//MARK: Data table delegate
extension WorkItemViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Find how many rows we have on the selected data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.model.getWorkItemsCountByDate(date: calendarView.startDate)
    }
    
    //MARK: TODO: Add rate and hours to the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCellIdentifier") as! WorkItemTableViewCell
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let workItemM = appDelegate.model.getWorkItemsByDate(date: calendarView.startDate, index: indexPath.item)
        
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        
        
        
        
      
        
        let earnings = workItemM.hours * workItemM.rate
        let hst = (earnings/100) * workItemM.hst
       
        cell.backgroundColor = UIColor(red:0.97, green:1.00, blue:1.00, alpha:1.0)
        cell.client.text = "ISED"
        
        if let dailyEarnings = formatter.string(from: earnings as NSNumber) {
            cell.earnings.text = dailyEarnings
        }
        
        if let dailyHST = formatter.string(from: hst as NSNumber) {
            cell.hst.text = dailyHST
        }
        
        cell.hours.text = String(format: "%.2f(hh)", workItemM.hours)
        
        if (!workItemM.workDescription.isEmpty) {
            cell.workDesc.text = workItemM.workDescription
        }
       
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

//MARK: Support for swipe to delete work items, need to build this out
extension WorkItemViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Knowing which cell we are dealing with
        //let cell = tableView.cellForRow(at: indexPath)
    }
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if editingStyle == .delete {
          
            
        appDelegate.model.deleteWorkItemsByDate(date: calendarView.startDate, index: indexPath.item)
        tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            print ("Got edit")
            // Not used in our example, but if you were adding a new row, this is where you would do it.
        }
    }
    
}


//MARK: Delegate for knowing if a work item was added
extension WorkItemViewController: WorkItemAdded {
     func didAddWorkItem(addedItem: Bool) {
        self.dailyItemsTableView.reloadData()
        let today = calendarView.startDate
        //ToDo: Add another colour for the days we have expenses
//        calendarView.setSupplementaries([
//            (today, [VADaySupplementary.bottomDots([.green, .magenta])]),
//            ])
        calendarView.setSupplementaries([
                    (today, [VADaySupplementary.bottomDots([.gray])]),
                    ])
    }
}

//Extension to support date manipulation
extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}

//MARK: Cal view apperance delegate
extension WorkItemViewController: VADayViewAppearanceDelegate {
    
    func textColor(for state: VADayState) -> UIColor {
        switch state {
        case .out:
            return UIColor(red: 214 / 255, green: 214 / 255, blue: 219 / 255, alpha: 1.0)
        case .selected:
            return .white
        case .unavailable:
            return .lightGray
        default:
            return .black
        }
    }
    
    func textBackgroundColor(for state: VADayState) -> UIColor {
        switch state {
        case .selected:
            return UIColor(red:0.77, green:0.90, blue:0.90, alpha:1.0)
        default:
            return .clear
        }
    }
    
    func shape() -> VADayShape {
        return .circle
    }
}
