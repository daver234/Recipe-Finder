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
    func retrievedSavedRecipePages(pageNumber: Int, searchTerm: String) -> [RecipePage]? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil}
        var recipePagesToReturn = [RecipePage]()
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.MRECIPE_PAGE)
            let sort = NSSortDescriptor(key: Constants.MCREATED_AT_PAGE, ascending: false)
            fetchRequest.sortDescriptors = [sort]
            do {
                // var recipePage: [RecipePage]?
                
                let result = try managedContext.fetch(fetchRequest)
                for item in result {
                    if let createdAt = item.value(forKey: Constants.MCREATED_AT_PAGE),
                        let term = item.value(forKey: Constants.MSEARCH_TERM),
                        let page = item.value(forKey: Constants.MPAGE_NUMBER),
                        let recipe = item.value(forKey: Constants.MRECIPES) {
                        print("here is createdAt:\(createdAt), searchTerm \(term) & page number \(page)")
                        var pageToAdd = RecipePage()
                        pageToAdd.pageNumber = page as? Int
                        pageToAdd.searchTerm = term as? String
                        pageToAdd.recipes = recipe as? [Recipe]
//                        var recipeDetail =  Recipe()
//                        for element in pageToAdd.recipes! {
//                            recipeDetail.imageUrl  = element.imageUrl
//                            recipeDetail.publisher = element.publisher
//                            recipeDetail.publisherUrl = element.publisherUrl
//                            recipeDetail.recipeID = element.recipeID
//                            recipeDetail.socialRank = element.socialRank
//                            recipeDetail.sourceUrl = element.sourceUrl
//                            recipeDetail.title = element.title
//                            recipeDetail.url = element.url
//                            pageToAdd.recipes?.append(recipeDetail)
//                        }
                        recipePagesToReturn.append(pageToAdd)
                    }
                }
                print("$$$$ here is struct recipePage", recipePagesToReturn)
//                let count = recipePagesToReturn.count
//                for index in 1...count {
//                    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.MRECIPE_DETAIL)
//                    let sortDescriptor = NSSortDescriptor(key: Constants.MPAGE_NUMBER, ascending: true)
//                    let predicate = NSPredicate(format: "mRecipePage == %@", index)
//                    fetchRequest.sortDescriptors = [sortDescriptor]
//                    fetchRequest.predicate = predicate
//                    do {
//                        let newerResult = try managedContext.fetch(fetchRequest)
//                        for item in newerResult {
//                            var recipe = Recipe()
//                            guard let title = item.value(forKey: Constants.MTITLE),
//                                let recipeID = item.value(forKey: Constants.MRECIPE_ID),
//                                let imageUrl = item.value(forKey: Constants.MIMAGE_URL),
//                                let publisher = item.value(forKey: Constants.MPUBLISHER),
//                                let publisherUrl = item.value(forKey: Constants.MPUBLISER_URL),
//                                let socialRank = item.value(forKey: Constants.MSOCIAL_RANK),
//                                let url = item.value(forKey: Constants.MURL),
//                                let sourceUrl = item.value(forKey: Constants.MSOURCE_URL)  else { return nil}
//
//                            recipe.title = title as? String
//                            recipe.recipeID = recipeID as? String
//                            recipe.imageUrl = imageUrl as? String
//                            recipe.publisher = publisher as? String
//                            recipe.publisherUrl = publisherUrl as? String
//                            recipe.socialRank = socialRank as? Double
//                            recipe.url = url as? String
//                            recipe.sourceUrl = sourceUrl as? String
//                            print("here is title:\(title) and then recipeID \(recipeID)")
//                            recipePagesToReturn[index].recipes?.append(recipe)
//                            print("****** recipePagesToReturn", recipePagesToReturn)
//                        }
//                    } catch {
//                        print("error getting Recipe")
//                    }
//
//
//
//                }
                
                let newFetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.MRECIPE_DETAIL)
                let sortDescriptor = NSSortDescriptor(key: Constants.MCREATED_AT_RECIPE, ascending: true)
                newFetchRequest.sortDescriptors = [sortDescriptor]
                let newResult = try managedContext.fetch(newFetchRequest)
                let pageCount = recipePagesToReturn.count
                let recipeCount = newResult.count
                print("newResult count", newResult.count)
                print("recipePagesToReturn count", recipePagesToReturn.count)
                var recipesAddedCounter = 0
                var pagesDone = 0
//                for element in 1...pageCount {
//                    // guard let recipePage = recipePagesToReturn[element].recipes[element] else { return nil }
//                    let indexStart =
//                    for newItem in  {
//                        guard let title = newItem.value(forKey: Constants.MTITLE), let recipeID = newItem.value(forKey: Constants.MRECIPE_ID) else { return nil }
//
//
//                    }
//                }
                for item in newResult {
//                    if let title = item.value(forKey: Constants.MTITLE), let recipeID = item.value(forKey: Constants.MRECIPE_ID), let createdAt = item.value(forKey: Constants.MCREATED_AT_RECIPE) {
//                        print("here is title:\(title) and then recipeID \(recipeID) and createdAt \(createdAt)")
//                    }
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
                    //print("here is title:\(title) and then recipeID \(recipeID)")
                    //recipePagesToReturn[index].recipes?.append(recipe)
                    //print("****** recipePagesToReturn", recipePagesToReturn)
                    recipePagesToReturn[pagesDone].recipes = [recipe]
                    
                    print("here is title:\(title) and then recipeID \(recipeID)")
                    recipesAddedCounter += 1
                    print("pagesDone is \(pagesDone) and recipesAddedCounter is \(recipesAddedCounter)")
                    if recipesAddedCounter % 30 == 0 {
                        pagesDone += 1
                    }
                    if pagesDone == pageCount {
                        print("recipePagesToReturn", recipePagesToReturn)
                        break
                    }
                }
               return recipePagesToReturn
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
        return recipePagesToReturn
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
