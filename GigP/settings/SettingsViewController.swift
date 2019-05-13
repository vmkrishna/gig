//
//  SettingsViewController.swift
//  GigP
//
//  Created by Krishna Vemulapali on 2019-05-04.
//  Copyright © 2019 Krishna Vemulapali. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet var clientName: UITextField!
    @IBOutlet var clientRate: UITextField!
    @IBOutlet var clientHST: UITextField!
    @IBOutlet var clientPhoneNumber: UITextField!
    @IBOutlet var clientEmail: UITextField!
    @IBOutlet var clientAddress: UITextField!
    
    //test
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))

        // Do any additional setup after loading the view.
    }
    @IBAction func dismissSettings(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    @IBAction func addNewClient(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
       
        guard let hst = Float(clientHST.text!) else { return }
        guard let rate = Float(clientRate.text!) else { return }
        
        
        let clientM = ClientM(clientName: clientName.text!, clientEmail: clientEmail.text!, clientAddress: clientAddress.text!, clientPhoneNumber: clientPhoneNumber.text!, clientRate: rate, clientHST: hst)
        appDelegate.model.saveClient(client: clientM)
        
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
