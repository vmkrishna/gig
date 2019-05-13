//
//  DataModel.swift
//  GigP
//
//  Created by Krishna Vemulapali on 2019-04-22.
//  Copyright © 2019 Krishna Vemulapali. All rights reserved.
//

import UIKit
import CoreData

class WorkItemM{
    var workDescription: String
    var hours: Float
    var hst: Float
    var rate: Float
    var date: Date
    
    init(workDescripton: String, hours: Float?, hst: Float, rate: Float, date: Date) {
        self.workDescription = workDescripton
        self.hours = hours!
        self.hst = hst
        self.rate = rate
        self.date = date
    }
}

class ClientM {
    var clientName: String
    var clientEmail: String
    var clientPhoneNumber: String
    var clientAddress: String
    var clientRate: Float
    var clientHST: Float
    
    init(clientName: String, clientEmail: String, clientAddress: String, clientPhoneNumber: String, clientRate: Float, clientHST: Float) {
        self.clientName = clientName
        self.clientEmail = clientEmail
        self.clientAddress = clientAddress
        self.clientPhoneNumber = clientPhoneNumber
        self.clientRate = clientRate
        self.clientHST = clientHST
    }
}
