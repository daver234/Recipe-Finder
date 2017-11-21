//
//  RetrieveRecipes.swift
//  BlueCart
//
//  Created by David Rothschild on 11/20/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import Foundation
import CoreData
import UIKit


/// Retrieve saved recipe pages from CoreData model
class RetrieveRecipes {

    /// Retrieved saved recipe pages from core data
    /// - Returns [NSManagedObject]
    func retrievedSavedRecipePages()  {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return  }
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.MRECIPE_PAGE)
            let sort = NSSortDescriptor(key: Constants.MCREATED_AT_PAGE, ascending: false)
            fetchRequest.sortDescriptors = [sort]
            do {
                let result = try managedContext.fetch(fetchRequest)
                for item in result {
                    if let createdAt = item.value(forKey: Constants.MCREATED_AT_PAGE),
                        let searchTerm = item.value(forKey: Constants.MSEARCH_TERM) {
                        print("here is createdAt:\(createdAt) and then searchTerm \(searchTerm)")
                    }
                }
                let newFetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.MRECIPE_DETAIL)
                let newResult = try managedContext.fetch(newFetchRequest)
                for item in newResult {
                    if let title = item.value(forKey: Constants.MTITLE), let recipeID = item.value(forKey: Constants.MRECIPE_ID) {
                        print("here is title:\(title) and then searchTerm \(recipeID)")
                    }
                }
                //return result
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                //return nil
            }
            
        } else {
            // Fallback on earlier versions of iOS
            let managedContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.MRECIPE_PAGE) //<NSManagedObject>(entityName: Constants.SEARCH_ENTITY)
            let entityDesc = NSEntityDescription.entity(forEntityName: Constants.MRECIPE_PAGE, in: managedContext)
            fetchRequest.entity = entityDesc
            do {
                var result = [NSManagedObject]()
                let records = try managedContext.fetch(fetchRequest)
                if let records = records as? [NSManagedObject] {
                    result = records
                }
                for item in result {
                    if let createdAt = item.value(forKey: Constants.MCREATED_AT_PAGE),
                        let searchTerm = item.value(forKey: Constants.MSEARCH_TERM) {
                        print("here is createdAt:\(createdAt) and then searchTerm \(searchTerm)")
                    }
                }
                let newFetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.MRECIPE_DETAIL)
                let newResult = try managedContext.fetch(newFetchRequest)
                for item in newResult {
                    if let title = item.value(forKey: Constants.MTITLE), let recipeID = item.value(forKey: Constants.MRECIPE_ID) {
                        print("here is title:\(title) and then searchTerm \(recipeID)")
                    }
                }
                //return result
            } catch {
                print("Could not fetch. \(error)")
                //return nil
            }
        }
    }
    
    /// Function to check if the recipe page results have already been saved
    /// - Parameter pageNumber: See if this page number has been stored
    /// - Parameter searchTerm: See if this search term on the above page number has been stored
    /// - Return bool:  True if it exists.  False if it does not exist.
    func retrievePageNumberAndSearchTerm(pageNumber: Int, searchTerm: String) -> Bool? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        var responseBool = false
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.MRECIPE_PAGE)
            do {
                let result = try managedContext.fetch(fetchRequest)
                for item in result {
                    guard let storedPageNumber = item.value(forKey: Constants.MPAGE_NUMBER), let storedSearchTerm = item.value(forKey: Constants.MSEARCH_TERM) else { return nil }
                    let intStoredPageNumber = storedPageNumber as! Int
                    let stringStoredSearchTerm = storedSearchTerm as! String
                    print("here is createdAt:\(pageNumber) and then searchTerm \(searchTerm)")
                    if (intStoredPageNumber == pageNumber) && (stringStoredSearchTerm == searchTerm) {
                        responseBool = true
                    }
                }
                return responseBool
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                return nil
            }
            
        } else {
            // Fallback on earlier versions of iOS
            let managedContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.MRECIPE_PAGE) //<NSManagedObject>(entityName: Constants.SEARCH_ENTITY)
            let entityDesc = NSEntityDescription.entity(forEntityName: Constants.MRECIPE_PAGE, in: managedContext)
            fetchRequest.entity = entityDesc
            do {
                var result = [NSManagedObject]()
                let records = try managedContext.fetch(fetchRequest)
                if let records = records as? [NSManagedObject] {
                    result = records
                }
                for item in result {
                    guard let storedPageNumber = item.value(forKey: Constants.MPAGE_NUMBER), let storedSearchTerm = item.value(forKey: Constants.MSEARCH_TERM) else { return nil }
                    let intStoredPageNumber = storedPageNumber as! Int
                    let stringStoredSearchTerm = storedSearchTerm as! String
                    print("here is createdAt:\(pageNumber) and then searchTerm \(searchTerm)")
                    if (intStoredPageNumber == pageNumber) && (stringStoredSearchTerm == searchTerm) {
                        responseBool = true
                    }
                }
                return responseBool
            } catch {
                print("Could not fetch. \(error)")
                return nil
            }
        }
    }
    
}
