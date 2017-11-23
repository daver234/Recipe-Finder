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
class SaveRecipes {

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
    /// - Parameter searchTerm: The recipe search term the user entered.
    /// - Parameter pageNumber: The page number, from the server, that is being saved.  Starts at 1.
    /// - Parameter recipePage: The RecipePage that was decoded from the JSON recieved from the server.
    func saveRecipePageCoreData(searchTerm: String, pageNumber: Int, recipePage: RecipePage) {
        DispatchQueue.main.async {
            guard let alreadySaved = RetrieveRecipes().retrievePageNumberAndSearchTerm(pageNumber: pageNumber, searchTerm: searchTerm) else { return }
            guard !alreadySaved else { return }
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            if #available(iOS 10.0, *) {
                let managedContext = appDelegate.persistentContainer.viewContext
                guard let entity = NSEntityDescription.entity(forEntityName: Constants.MRECIPE_PAGE, in: managedContext) else { return }
                let recipePageToSave = NSManagedObject(entity: entity, insertInto: managedContext)
                recipePageToSave.setValue(Date(), forKey: Constants.MCREATED_AT_PAGE)
                recipePageToSave.setValue(pageNumber, forKey: Constants.MPAGE_NUMBER)
                recipePageToSave.setValue(recipePage.count, forKey: Constants.MCOUNT)
                recipePageToSave.setValue(searchTerm, forKey: Constants.MSEARCH_TERM)
                for item in recipePage.recipes! {
                    let recipe = NSEntityDescription.insertNewObject(forEntityName: Constants.MRECIPE_DETAIL, into: managedContext)
                    recipe.setValue(Date(), forKey: Constants.MCREATED_AT_RECIPE)
                    recipe.setValue(item.imageUrl, forKey: Constants.MIMAGE_URL)
                    recipe.setValue(item.ingredients , forKey: Constants.MINGREDIENTS)
                    recipe.setValue(item.publisher , forKey: Constants.MPUBLISHER)
                    recipe.setValue(item.publisherUrl , forKey: Constants.MPUBLISER_URL)
                    recipe.setValue(item.recipeID , forKey: Constants.MRECIPE_ID)
                    recipe.setValue(item.socialRank , forKey: Constants.MSOCIAL_RANK)
                    recipe.setValue(item.sourceUrl , forKey: Constants.MSOURCE_URL)
                    recipe.setValue(item.title , forKey: Constants.MTITLE)
                    recipe.setValue(item.url , forKey: Constants.MURL)
                    recipePageToSave.setValue((NSSet(object: recipe)), forKey: Constants.MRECIPES)
                }
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
                recipePageToSave.setValue(searchTerm, forKey: Constants.MSEARCH_TERM)
                for item in recipePage.recipes! {
                    let recipe = NSEntityDescription.insertNewObject(forEntityName: Constants.MRECIPE_DETAIL, into: managedContext)
                    recipe.setValue(Date(), forKey: Constants.MCREATED_AT_RECIPE)
                    recipe.setValue(item.imageUrl, forKey: Constants.MIMAGE_URL)
                    recipe.setValue(item.ingredients , forKey: Constants.MINGREDIENTS)  /// need to change this
                    recipe.setValue(item.publisher , forKey: Constants.MPUBLISHER)
                    recipe.setValue(item.publisherUrl , forKey: Constants.MPUBLISER_URL)
                    recipe.setValue(item.recipeID , forKey: Constants.MRECIPE_ID)
                    recipe.setValue(item.socialRank , forKey: Constants.MSOCIAL_RANK)
                    recipe.setValue(item.sourceUrl , forKey: Constants.MSOURCE_URL)
                    recipe.setValue(item.title , forKey: Constants.MTITLE)
                    recipe.setValue(item.url , forKey: Constants.MURL)
                    recipePageToSave.setValue((NSSet(object: recipe)), forKey: Constants.MRECIPES)
                }
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    
    /// Function to take existing recipe and add the ingredients string array
    /// When retrieving the original recipe from the page of recipes, the ingredient list is not included.
    /// A second call needs to be made to get the recipe detail that includes the ingredients.
    /// - Parameter recipeDetail: Pass in an existing recipe
    func saveIngredietsToRecipe(ingredients: [String], recipeID: String) {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            if #available(iOS 10.0, *) {
                let managedContext = appDelegate.persistentContainer.viewContext
                let newFetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.MRECIPE_DETAIL)
                newFetchRequest.predicate = NSPredicate(format: "mRecipeID == \(recipeID)")
                do {
                    let newResult = try managedContext.fetch(newFetchRequest)
                    guard newResult.count != 0 else { return }  // if recipeID does not exist then exit
                    guard let first = newResult.first else { return }
                    first.setValue(ingredients , forKey: Constants.MINGREDIENTS)
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not update and save ingredients. \(error), \(error.userInfo)")
                }
            } else {
                // Fallback on earlier versions of iOS
                let managedContext = appDelegate.managedObjectContext
                let newFetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.MRECIPE_DETAIL)
                // guard let recipeID = recipeDetail.recipeID else { return }
                newFetchRequest.predicate = NSPredicate(format: "mRecipeID == \(recipeID)")
                do {
                    let newResult = try managedContext.fetch(newFetchRequest)
                    guard newResult.count != 0 else { return }  // if recipeID does not exist then exit
                    guard let first = newResult.first else { return }
                    first.setValue(ingredients , forKey: Constants.MINGREDIENTS)
                    try managedContext.save()
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not update and save ingredients. \(error), \(error.userInfo)")
                }
            }
        }
    }
}
