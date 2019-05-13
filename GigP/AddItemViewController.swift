//
//  AddItemViewController.swift
//  GigP
//
//  Created by Krishna Vemulapali on 2019-04-20.
//  Copyright © 2019 Krishna Vemulapali. All rights reserved.
//

import UIKit
import CoreData
import BottomPopup
import MaterialComponents.MaterialTextFields


//To allow data to be passed back to the previous view
protocol WorkItemAdded {
    func didAddWorkItem(addedItem : Bool)
}

class AddItemViewController: BottomPopupViewController {

    var delegate : WorkItemAdded?
    var workItemDate: Date?
    
    @IBOutlet var displayDateLabel: UILabel!
    @IBOutlet weak var hoursText: MDCTextField!
    @IBOutlet weak var rateText: MDCTextField!
    @IBOutlet weak var hstText: MDCTextField!
    
    @IBOutlet var clientList: UIPickerView!
    @IBOutlet var workPerformed: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let formattedDate = format.string(from: workItemDate ?? Date())
        
        displayDateLabel.text = formattedDate
        
        workPerformed.clearsOnInsertion = true
        
        //workPerformed.placeH text = "Debug & Bug Fixes"
        hoursText.text = "7.5"
        rateText.text = "77.33"
        hstText.text = "13"
        
        //To dismiss keyboard by tapping anywhere on the view
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
       
    }
    
    @IBAction func dissmissWorkItem(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addWorkItem(_ sender: Any) {
        //Save to database and dismiss view
        saveWorkItem()
        //Let our parent view know that an add was performed
        if delegate != nil {
            delegate?.didAddWorkItem(addedItem: true)
        }
        self.dismiss(animated: true)
    }
    
    override func getPopupHeight() -> CGFloat {
        return 900;
    }
    
    func saveWorkItem() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let hst = Float(hstText.text!) else { return }
        guard let rate = Float(rateText.text!) else { return }
        let hours = Float(hoursText.text!)

        
        let workItemM = WorkItemM(workDescripton: workPerformed.text ?? "", hours: hours, hst: hst, rate: rate, date: self.workItemDate!)
        appDelegate.model.saveWorkItem(workItem: workItemM)
    }

}


extension AddItemViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        //workPerformed.text = String()
    }
}

extension AddItemViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.model.getAllClients().count
    }
}

extension AddItemViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return (appDelegate.model.getAllClients())[row].clientName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Row selected")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //Change based on the client selected
        rateText.text = String( (appDelegate.model.getAllClients())[row].clientRate)
        hstText.text =  String( (appDelegate.model.getAllClients())[row].clientHST)
    }
}
    


