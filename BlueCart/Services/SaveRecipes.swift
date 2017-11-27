//
//  SaveRecipes.swift
//  BlueCart
//
//  Created by David Rothschild on 11/16/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import Foundation
import UIKit
import CoreData

/// Saving recipe lists and recipe detail for retrieval when device is offline
class SaveRecipes {

    /// Saving RecipePage to Core Data
    /// Handles iOS 10 and above one way and iOS 9 and below another
    /// - Parameter searchTerm: The recipe search term the user entered.
    /// - Parameter pageNumber: The page number, from the server, that is being saved.  Starts at 1.
    /// - Parameter recipePage: The RecipePage that was decoded from the JSON recieved from the server.
    func saveRecipePageToCoreData(searchTerm: String, pageNumber: Int, recipePage: RecipePage) {
        DispatchQueue.main.async {
            guard let alreadySaved = RetrieveRecipes().retrievePageNumberAndSearchTerm(pageNumber: pageNumber, searchTerm: searchTerm) else { return }
            guard !alreadySaved else { return }
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            if #available(iOS 10.0, *) {
                let managedContext = appDelegate.persistentContainer.viewContext
                let page = MRecipePage(context: managedContext)
                page.mCreatedAt = Date()
                page.mPageNumber = Int16(pageNumber)
                guard let count = recipePage.count else { return }
                page.mCount = Int16(count)
                page.mSearchTerm = searchTerm
                for item in recipePage.recipes! {
                    let recipe = MRecipeDetail(context: managedContext)
                    recipe.mCreatedAt = Date()
                    recipe.mImageUrl = item.imageUrl
                    recipe.mIngredients = nil
                    recipe.mPublisher = item.publisher
                    recipe.mPublisherUrl = item.publisherUrl
                    recipe.mRecipeID = item.recipeID
                    guard let rank = item.socialRank else { continue }
                    recipe.mSocialRank = rank
                    recipe.mSourceUrl = item.sourceUrl
                    recipe.mTitle = item.title
                    recipe.mUrl = item.url
                    recipe.mSearchTerm = searchTerm.lowercased()
                    page.addToMRecipes(recipe)
                }
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save recipe page. \(error), \(error.userInfo)")
                }
            } else {
                let managedContext = appDelegate.managedObjectContext
                guard let entityDesc = NSEntityDescription.entity(forEntityName: Constants.MRECIPE_PAGE, in: managedContext) else { return }
                let recipePageToSave = NSManagedObject(entity: entityDesc, insertInto: managedContext)
                recipePageToSave.setValue(Date(), forKey: Constants.MCREATED_AT_PAGE)
                recipePageToSave.setValue(pageNumber, forKey: Constants.MPAGE_NUMBER)
                recipePageToSave.setValue(recipePage.count, forKey: Constants.MCOUNT)
                recipePageToSave.setValue(searchTerm, forKey: Constants.MSEARCH_TERM)
                for item in recipePage.recipes! {
                    let newRecipe = NSManagedObject(entity: entityDesc, insertInto: managedContext)
                    newRecipe.setValue(Date(), forKey: Constants.MCREATED_AT_RECIPE)
                    newRecipe.setValue(item.imageUrl, forKey: Constants.MIMAGE_URL)
                    newRecipe.setValue(item.ingredients , forKey: Constants.MINGREDIENTS)
                    newRecipe.setValue(item.publisher , forKey: Constants.MPUBLISHER)
                    newRecipe.setValue(item.publisherUrl , forKey: Constants.MPUBLISER_URL)
                    newRecipe.setValue(item.recipeID , forKey: Constants.MRECIPE_ID)
                    newRecipe.setValue(item.socialRank , forKey: Constants.MSOCIAL_RANK)
                    newRecipe.setValue(item.sourceUrl , forKey: Constants.MSOURCE_URL)
                    newRecipe.setValue(item.title , forKey: Constants.MTITLE)
                    newRecipe.setValue(item.url , forKey: Constants.MURL)
                    let recipes = recipePageToSave.mutableSetValue(forKey: "mRecpies")
                    recipes.add(newRecipe)
                    // recipePageToSave.setValue((NSSet(object: recipe)), forKey: Constants.MRECIPES)
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
    /// - Parameter ingredients: Pass in the ingredients list for the recipe
    /// - Parameter recipeID: The id of the recipe to save
    func saveIngredietsToRecipe(ingredients: [String], recipeID: String) {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            if #available(iOS 10.0, *) {
                let managedContext = appDelegate.persistentContainer.viewContext
                let newFetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.MRECIPE_DETAIL)
                newFetchRequest.predicate = NSPredicate(format: "mRecipeID == %@", recipeID)
                do {
                    let newResult = try managedContext.fetch(newFetchRequest)
                    guard newResult.count != 0 else { print("recipeID does not seem to exist so zero?.", newResult.count);  return }  // if recipeID does not exist then exit
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
                newFetchRequest.predicate = NSPredicate(format: "mRecipeID == %@", recipeID)
                do {
                    let newResult = try managedContext.fetch(newFetchRequest)
                    guard newResult.count != 0 else { return }  // if recipeID does not exist then exit
                    guard let first = newResult.first else { return }
                    first.setValue(ingredients , forKey: Constants.MINGREDIENTS)
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not update and save ingredients. \(error), \(error.userInfo)")
                }
            }
        }
    }
}
