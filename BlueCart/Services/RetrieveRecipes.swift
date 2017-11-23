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

    /// Retrieved saved recipes from Core Data
    /// - Parameter searchTerm: The type of recipes the user wants to retrieve
    /// - Returns [Recipe]: All the recipes saved for the search term
    func retrievedSavedRecipes(searchTerm: String) -> [Recipe]? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil}
        var recipesToReturn = [Recipe]()
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
            do {
                let newFetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.MRECIPE_DETAIL)
                let sortDescriptor = NSSortDescriptor(key: Constants.MCREATED_AT_RECIPE, ascending: true)
                newFetchRequest.sortDescriptors = [sortDescriptor]
                let newResult = try managedContext.fetch(newFetchRequest)
                var recipesAddedCounter = 0
                for item in newResult {
                    var recipe = Recipe()
                    guard let title = item.value(forKey: Constants.MTITLE),
                        let recipeID = item.value(forKey: Constants.MRECIPE_ID),
                        let imageUrl = item.value(forKey: Constants.MIMAGE_URL),
                        let publisher = item.value(forKey: Constants.MPUBLISHER),
                        let publisherUrl = item.value(forKey: Constants.MPUBLISER_URL),
                        let socialRank = item.value(forKey: Constants.MSOCIAL_RANK),
                        let url = item.value(forKey: Constants.MURL),
                        let sourceUrl = item.value(forKey: Constants.MSOURCE_URL)  else { return nil}
                    recipe.title = title as? String
                    recipe.recipeID = recipeID as? String
                    recipe.imageUrl = imageUrl as? String
                    recipe.publisher = publisher as? String
                    recipe.publisherUrl = publisherUrl as? String
                    recipe.socialRank = socialRank as? Double
                    recipe.url = url as? String
                    recipe.sourceUrl = sourceUrl as? String
                    recipesToReturn.append(recipe)
                    recipesAddedCounter += 1
                }
               return recipesToReturn 
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                return nil
            }
            
        } else {
            // Fallback on earlier versions of iOS
            let managedContext = appDelegate.managedObjectContext
            //let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.MRECIPE_PAGE)
            //let entityDesc = NSEntityDescription.entity(forEntityName: Constants.MRECIPE_PAGE, in: managedContext)
            //fetchRequest.entity = entityDesc
            do {
                let newFetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.MRECIPE_DETAIL)
                let sortDescriptor = NSSortDescriptor(key: Constants.MCREATED_AT_RECIPE, ascending: true)
                newFetchRequest.sortDescriptors = [sortDescriptor]
                let newResult = try managedContext.fetch(newFetchRequest)
                var recipesAddedCounter = 0
                for item in newResult {
                    var recipe = Recipe()
                    guard let title = item.value(forKey: Constants.MTITLE),
                        let recipeID = item.value(forKey: Constants.MRECIPE_ID),
                        let imageUrl = item.value(forKey: Constants.MIMAGE_URL),
                        let publisher = item.value(forKey: Constants.MPUBLISHER),
                        let publisherUrl = item.value(forKey: Constants.MPUBLISER_URL),
                        let socialRank = item.value(forKey: Constants.MSOCIAL_RANK),
                        let url = item.value(forKey: Constants.MURL),
                        let sourceUrl = item.value(forKey: Constants.MSOURCE_URL)  else { return nil}
                    recipe.title = title as? String
                    recipe.recipeID = recipeID as? String
                    recipe.imageUrl = imageUrl as? String
                    recipe.publisher = publisher as? String
                    recipe.publisherUrl = publisherUrl as? String
                    recipe.socialRank = socialRank as? Double
                    recipe.url = url as? String
                    recipe.sourceUrl = sourceUrl as? String
                    recipesToReturn.append(recipe)
                    recipesAddedCounter += 1
                }
                return recipesToReturn
            } catch {
                print("Could not fetch. \(error)")
                return nil
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
                    //print("here is createdAt:\(pageNumber) and then searchTerm \(searchTerm)")
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
                    //print("here is createdAt:\(pageNumber) and then searchTerm \(searchTerm)")
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
