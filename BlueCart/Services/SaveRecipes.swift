//
//  SaveRecipes.swift
//  BlueCart
//
//  Created by David Rothschild on 11/16/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import Foundation
import Disk
import CoreData

/// Saving recipe lists and recipe detail for retrieval when device is offline
/// Using Disk 3rd party framework.
class SaveRecipes {
    /// Save RecipePage for use in offline
    /// - Parameter searchString. The recipes being searched for.
    /// - Parameter data. The data returned from the server.  Decoded when retrived
    func saveRecipePageForOffline(searchString: String, data: Data) {
        let termTrimmed = searchString.lowercased().replacingOccurrences(of: " ", with: "")
        do {
            if Disk.exists("\(termTrimmed)", in: .caches) {
                try Disk.append(data, to: "Recipe/", in: .caches)
            } else {
                try Disk.save(data, to: .caches, as: "Recipe/\(termTrimmed)")
            }
            
        } catch let error as NSError  {
            fatalError("""
                Domain: \(error.domain)
                Code: \(error.code)
                Description: \(error.localizedDescription)
                Failure Reason: \(error.localizedFailureReason ?? "")
                Suggestions: \(error.localizedRecoverySuggestion ?? "")
                """)
        }
    }
    
    /// Save RecipeDetail (using Disk framework) for use in offline. This file contains the ingredients.
    /// - Parameter recipeId: This id becomes the file name to retrive later.
    /// - Parameter completion: The completion handler to execute with the data.
    func saveDetailForOffline(recipeId: String, data: Data) {
        do {
            try Disk.save(data, to: .caches, as: "\(recipeId)")
        } catch let error as NSError  {
            fatalError("""
                Domain: \(error.domain)
                Code: \(error.code)
                Description: \(error.localizedDescription)
                Failure Reason: \(error.localizedFailureReason ?? "")
                Suggestions: \(error.localizedRecoverySuggestion ?? "")
                """)
        }
    }
    
    /// Saving RecipePage to Core Data
    /// Handles iOS 10 and above one way and iOS 9 and below another
    /// - Parameter pageNumber: The page number, from the server, that is being saved.  Starts at 1.
    func saveRecipePageCoreData(pageNumber: Int, recipePage: RecipePage) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
            guard let entity = NSEntityDescription.entity(forEntityName: Constants.MRECIPE_PAGE, in: managedContext) else { return }
            let recipePageToSave = NSManagedObject(entity: entity, insertInto: managedContext)
            recipePageToSave.setValue(Date(), forKey: Constants.MCREATED_AT_PAGE)
            recipePageToSave.setValue(pageNumber, forKey: Constants.MPAGE_NUMBER)
            recipePageToSave.setValue(recipePage.count, forKey: Constants.MCOUNT)
            // recipePageToSave.setValue(recipePage.recipes, forKey: )
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        } else {
            // Fallback on earlier versions of iOS
            let managedContext = appDelegate.managedObjectContext
            guard let entityDesc = NSEntityDescription.entity(forEntityName: Constants.SEARCH_ENTITY, in: managedContext) else { return }
            let recipePageToSave = NSManagedObject(entity: entityDesc, insertInto: managedContext)
            recipePageToSave.setValue(Date(), forKey: Constants.MCREATED_AT_PAGE)
            recipePageToSave.setValue(pageNumber, forKey: Constants.MPAGE_NUMBER)
            recipePageToSave.setValue(recipePage.count, forKey: Constants.MCOUNT)
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
}
