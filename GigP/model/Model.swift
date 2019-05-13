//
//  Model.swift
//  GigP
//
//  Created by Krishna Vemulapali on 2019-04-22.
//  Copyright © 2019 Krishna Vemulapali. All rights reserved.
//

import UIKit
import CoreData

class Model {
    var workItems:  [WorkItemM] = []
    var clients: [ClientM] = []
    let container = NSPersistentContainer(name: "gig")
 
    init() {
        print(container.persistentStoreDescriptions.first?.url!)
        let context = persistentContainer.viewContext
        
        initWorkItems(context: context)
        initClients(context: context)
        //Perform any inits here, read from database and populate the model
    }
    
    func initWorkItems(context: NSManagedObjectContext) {
        
        let fetchRequest = NSFetchRequest<WorkItem>(entityName: "WorkItem")
        do {
            let fetchedResults = try context.fetch(fetchRequest)
            for item in fetchedResults {
                let workDesc = item.value(forKey: "workPerformed")! as! String
                let hours =  item.value(forKey: "hours")! as! Float
                let rate = item.value(forKey: "rate")! as! Float
                let hst =  item.value(forKey: "hst")! as! Float
                let date = item.value(forKey: "date")
                var newDate: Date
                if date == nil {
                    newDate = Date()
                }else {
                    newDate = date as! Date
                }
                
                workItems.append( WorkItemM (workDescripton: workDesc,
                                           hours: hours,
                                           hst: hst,
                                           rate: rate,
                                           date: newDate))
            }
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func initClients(context: NSManagedObjectContext) {
        
        let fetchRequest = NSFetchRequest<Client>(entityName: "Client")
        do {
            let fetchedResults = try context.fetch(fetchRequest)
            for item in fetchedResults {
                let name = item.value(forKey: "name") as! String
                let address =  item.value(forKey: "address") as! String
                let phoneNumber = item.value(forKey: "phone") as! String
                var email = item.value(forKey: "email") as! String
                let rate = item.value(forKey: "rate")! as! Float
                let hst =  item.value(forKey: "hst")! as! Float
               
                
                clients.append( ClientM (clientName: name, clientEmail: email, clientAddress: address, clientPhoneNumber: phoneNumber, clientRate: rate, clientHST: hst))
                
            }
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func getAllClients() -> [ClientM] {
        return clients
    }
    
    
    func saveClient(client: ClientM) {
        let context = persistentContainer.viewContext
        clients.append(client)
        
        let entity = NSEntityDescription.entity(forEntityName: "Client", in: context)
        let clientMO = NSManagedObject(entity: entity!, insertInto: context)
        
        clientMO.setValue(client.clientName, forKey: "name")
        clientMO.setValue(client.clientPhoneNumber, forKey: "phone")
        clientMO.setValue(client.clientRate, forKey: "rate")
        clientMO.setValue(client.clientHST, forKey: "hst")
        clientMO.setValue(client.clientAddress, forKey: "address")
        clientMO.setValue(client.clientEmail, forKey: "email")
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func saveWorkItem(workItem: WorkItemM) {
        let context = persistentContainer.viewContext
        
        print (workItem.date)
        workItems.append(workItem)
        
        let entity = NSEntityDescription.entity(forEntityName: "WorkItem", in: context)
        let workItemMO = NSManagedObject(entity: entity!, insertInto: context)
        
        workItemMO.setValue(workItem.workDescription, forKey: "workPerformed")
        workItemMO.setValue(workItem.hst, forKey: "hst")
        workItemMO.setValue(workItem.rate, forKey: "rate")
        workItemMO.setValue(workItem.hours, forKey: "hours")
        workItemMO.setValue(workItem.date, forKey: "date")
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func deleteWorkItemsByDate(date: Date, index: Int) -> Bool{
        
        var indexList: [Int] = []
        var i = 0
        for item in workItems {
            i += 1
            if date == item.date {
                indexList.append(i)
            }
        }
        
        workItems.remove(at: indexList[index]-1)
        
        return deleteFromCoreData(date: date, index: index)
        
        
    }
    
    func deleteFromCoreData(date: Date, index: Int) -> Bool{
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<WorkItem>(entityName: "WorkItem")
        fetchRequest.predicate = NSPredicate(format: "date = %@", date as CVarArg)
        do {
            var fetchedResults = try context.fetch(fetchRequest)
            if (fetchedResults .isEmpty) {
                return true
            }
            var workItem = fetchedResults[index]
            context.delete(workItem)
            //save
            try context.save()
        } catch let error as NSError {
            print(error.description)
        }
        return true;
    }
    
    func getAllWorkItems() ->  [WorkItemM] {
        return workItems
    }
    
    func getWorkItemsCount() -> Int {
        return workItems.count
    }
    
    func getWorkItemsByDate(date: Date, index: Int) -> WorkItemM {
        var workItemsByDate:  [WorkItemM] = []
        for item in workItems {
            if date == item.date {
                workItemsByDate.append(item)
            }
        }
        return workItemsByDate[index]
    }
    
    func getWorkItemsCountByDate(date: Date) -> Int {
        var count = 0
        print (date)
        //var filterDay = Calendar.startOfDay(for date: date)
        for item in workItems {
            if date == item.date {
                count += 1
            }
        }
        return count
    }
    
    //MARK: Helper functions
    func getYearlyEarning() -> Float {
        var earnings: Float = 0
        for item in workItems {
            let dayE = (item.rate * item.hours)
            let daysTax = (dayE/100) * item.hst
            earnings += dayE + daysTax
        }
        return earnings;
    }
    
    func getYearlyHST() -> Float {
        var hst: Float = 0
        for item in workItems {
            
            let dayE = (item.rate * item.hours)
            let daysTax = (dayE/100) * item.hst
            hst += daysTax
        }
        return hst;
    }
    
    func getYearlyHours() -> Float {
        var hours: Float = 0
        for item in workItems {
            hours += item.hours
        }
        return hours;
    }
    
    func getEarningByMonth(monthStart: Date, monthEnd: Date) -> Float {
        var earnings: Float = 0
        let dateSortedWorkItems = workItems.sorted(by: { $0.date > $1.date })
        for item in dateSortedWorkItems {
            if (monthEnd > item.date && monthStart <= item.date) {
                let dayE = (item.rate * item.hours)
                let dayEWithTax = (dayE/100) * item.hst
                earnings += dayE + dayEWithTax
            }
        }
        return earnings
    }
    
    func getHSTByMonth(monthStart: Date, monthEnd: Date) -> Float {
        var hst: Float = 0
        let dateSortedWorkItems = workItems.sorted(by: { $0.date > $1.date })
        for item in dateSortedWorkItems {
            if (monthEnd > item.date && monthStart <= item.date) {
                let dayE = (item.rate * item.hours)
                let daysHST = (dayE/100) * item.hst
                hst += daysHST
            }
        }
        return hst
    }
    
    func getHoursByMonth(monthStart: Date, monthEnd: Date) -> Float {
        var hours: Float = 0
        let dateSortedWorkItems = workItems.sorted(by: { $0.date > $1.date })
        for item in dateSortedWorkItems {
            if (monthEnd > item.date && monthStart <= item.date) {
                hours += item.hours
            }
        }
        return hours
    }
    
    func getDaysWorked(monthStart: Date, monthEnd: Date) -> [Date ] {
        
        var daysWorked = [Date]()
        let dateSortedWorkItems = workItems.sorted(by: { $0.date > $1.date })
        for item in dateSortedWorkItems {
            if (monthEnd > item.date && monthStart <= item.date) {
               daysWorked.append(item.date)
            }
        }
        return daysWorked
    }
    
    //MARK End Helper functions
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "gig")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
