//
//  SearchTerms.swift
//  BlueCart
//
//  Created by David Rothschild on 11/22/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import Foundation
import CoreData
import UIKit

/// Functions to manage search terms entered by user
class SearchTerms {
    /// Saving search terms to CoreData
    /// Handles iOS 10 and above one way and iOS 9 and below another
    /// - Parameter term: The search term to save
    func saveSearchTermToCoreData(term: String) {
        let termLowercase = term.lowercased()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
            guard let entity = NSEntityDescription.entity(forEntityName: Constants.SEARCH_ENTITY, in: managedContext) else { return }
            let searchTerm = NSManagedObject(entity: entity, insertInto: managedContext)
            searchTerm.setValue(Date(), forKey: Constants.SEARCH_DATE)
            searchTerm.setValue(termLowercase, forKey: Constants.SEARCH_TERMS)
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        } else {
            // Fallback on earlier versions of iOS
            let managedContext = appDelegate.managedObjectContext
            guard let entityDesc = NSEntityDescription.entity(forEntityName: Constants.SEARCH_ENTITY, in: managedContext) else { return }
            let searchTerm = NSManagedObject(entity: entityDesc, insertInto: managedContext)
            searchTerm.setValue(term, forKey: Constants.SEARCH_TERMS)
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    /// Retrieve saved search terms from CoreData model
    /// - Returns [NSManagedObject]: Returns array of managed objects...search terms.
    func retrievedSavedSearchTerms() ->[NSManagedObject]? {
        var result = [NSManagedObject]()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.SEARCH_ENTITY)
            let sort = NSSortDescriptor(key: Constants.SEARCH_DATE, ascending: false)
            fetchRequest.sortDescriptors = [sort]
            do {
                // searchTerms.value = []
                result = try managedContext.fetch(fetchRequest)
                return result
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                return nil
            }
        } else {
            // Fallback on earlier versions of iOS
            let managedContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.SEARCH_ENTITY) //<NSManagedObject>(entityName: Constants.SEARCH_ENTITY)
            let entityDesc = NSEntityDescription.entity(forEntityName: Constants.SEARCH_ENTITY, in: managedContext)
            fetchRequest.entity = entityDesc
            do {
                guard let tempSearchTerms = try managedContext.fetch(fetchRequest) as? [NSManagedObject] else { return nil  }
                result = tempSearchTerms
                return result
            } catch {
                print("Could not fetch. \(error)")
                return nil
            }
        }
    }
    
    func deleteSearchTerm(searchTerm: NSManagedObject) {
        guard let managedContext = RetrieveRecipes().getManagedContext() else { return }
        managedContext.delete(searchTerm)
        do {
            try managedContext.save()
        } catch let saveErr {
            print("Failed to delete search term", saveErr)
        }
    }
}
