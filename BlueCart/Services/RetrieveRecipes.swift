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

    fileprivate func retrievedSavedRecipePages() -> [NSManagedObject]? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [NSManagedObject]() }
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.MRECIPE_PAGE)
            let sort = NSSortDescriptor(key: Constants.MCREATED_AT_PAGE, ascending: false)
            fetchRequest.sortDescriptors = [sort]
            do {
                //searchTerms.value = []
                let result = try managedContext.fetch(fetchRequest)
                return result
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
                guard let result = try managedContext.fetch(fetchRequest) as? [NSManagedObject] else { return  [NSManagedObject]() }
                return result
            } catch {
                print("Could not fetch. \(error)")
                return nil
            }
        }
    }
    
    
    
}
