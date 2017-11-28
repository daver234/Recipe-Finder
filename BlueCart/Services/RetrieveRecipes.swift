//
//  RetrieveRecipes.swift
//  BlueCart
//
//  Created by David Rothschild on 11/20/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import CoreData
import UIKit

/// Retrieve saved recipe pages and specific recipe from CoreData
class RetrieveRecipes {

    /// Retrieved saved recipes from Core Data
    /// - Parameter searchTerm: The type of recipes the user wants to retrieve
    /// - Parameter completion:  The completion handler returns the array of recipes that was stored.
    func retrievedSavedRecipes(searchTerm: String, completion: @escaping CompletionHandlerWithRecipes) {
        guard let managedContext = getManagedContext() else { return }
        var recipesToReturn = [Recipe]()
        
        // Need to check if the search is for Top Rated which means searchTerm is ""
        var revisedSearchTerm = ""
        searchTerm == "" ? (revisedSearchTerm = Constants.TOP_RATED) : (revisedSearchTerm = searchTerm)
        
        do {
            let newFetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.MRECIPE_DETAIL)
            let sortDescriptor = NSSortDescriptor(key: Constants.MCREATED_AT_RECIPE, ascending: true)
            newFetchRequest.sortDescriptors = [sortDescriptor]
            newFetchRequest.predicate = NSPredicate(format: "mSearchTerm == %@", revisedSearchTerm.lowercased())
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
                    let sourceUrl = item.value(forKey: Constants.MSOURCE_URL)  else { print("In continue"); continue }
                recipe.title = title as? String
                recipe.recipeID = recipeID as? String
                recipe.imageUrl = imageUrl as? String
                recipe.publisher = publisher as? String
                recipe.publisherUrl = publisherUrl as? String
                recipe.socialRank = socialRank as? Double
                recipe.url = url as? String
                recipe.sourceUrl = sourceUrl as? String
                
                /// If recipe detail was not viewed while online, then ingredients are nil.
                /// If this case, swap in a emtpy string array so that all recipes are returned.
                /// Ingredients attribute is updated when user views the particular recipe detail.
                let ingredients = item.value(forKey: Constants.MINGREDIENTS) ?? [""]
                recipe.ingredients = ingredients as? [String]
                recipesToReturn.append(recipe)
                recipesAddedCounter += 1
            }
           completion(recipesToReturn, nil)
        } catch {
            print("Could not fetch saved recipe pages from core data. \(error.localizedDescription)")
            completion(nil, error)
        }
    }
    
    /// Function to check if the recipe page results have already been saved.
    /// Need this so as to not save same recipe page twice.  When saving recipe page the first time,
    /// that function checks this function first.
    /// - Parameter pageNumber: See if this page number has been stored
    /// - Parameter searchTerm: See if this search term on the above page number has been stored
    /// - Return bool:  True if it exists.  False if it does not exist.
    func retrievePageNumberAndSearchTerm(pageNumber: Int, searchTerm: String) -> Bool? {
        guard let managedContext = getManagedContext() else { return nil }
        var responseBool = false
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.MRECIPE_PAGE)
        do {
            let result = try managedContext.fetch(fetchRequest)
            for item in result {
                guard let storedPageNumber = item.value(forKey: Constants.MPAGE_NUMBER), let storedSearchTerm = item.value(forKey: Constants.MSEARCH_TERM) else { return nil }
                let intStoredPageNumber = storedPageNumber as! Int
                let stringStoredSearchTerm = storedSearchTerm as! String
                if (intStoredPageNumber == pageNumber) && (stringStoredSearchTerm == searchTerm) {
                    responseBool = true
                }
            }
            return responseBool
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func getManagedContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil}
        if #available(iOS 10.0, *) {
            return appDelegate.persistentContainer.viewContext
        } else {
            return appDelegate.managedObjectContext
        }
    }
    
    /// Retrieve specific recipe for display in RecipeDetailVC
    func retrieveSpecificRecipe(recipeID: String) -> Recipe? {
        guard let managedContext = getManagedContext() else { return nil }
        let newFetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.MRECIPE_DETAIL)
        newFetchRequest.predicate = NSPredicate(format: "mRecipeID == %@", recipeID)
        do {
            let newResult = try managedContext.fetch(newFetchRequest)
            
            // If recipeID does not exist then exit
            guard newResult.count != 0 else { print("recipeID does not seem to exist so zero?.", newResult.count);  return nil }
            guard let first = newResult.first as? MRecipeDetail else { return nil }

            var recipe = Recipe()
            recipe.publisher = first.mPublisher
            recipe.url = first.mUrl
            recipe.title = first.mTitle
            recipe.sourceUrl = first.mSourceUrl
            recipe.recipeID = first.mRecipeID
            recipe.imageUrl = first.mImageUrl
            recipe.socialRank = first.mSocialRank
            recipe.publisherUrl = first.mPublisherUrl
            recipe.ingredients = first.mIngredients
            return recipe
        } catch let error as NSError {
            print("Could not retrieve recipe for recipeID. \(error), \(error.userInfo)")
            return nil
        }
    }

    
    /// Might use this general function for fetch requests - not in use now.
    private func fetchRecordsForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        var result = [NSManagedObject]()
        do {
            let records = try managedObjectContext.fetch(fetchRequest)
            if let records = records as? [NSManagedObject] {
                result = records
            }
        } catch {
            print("Unable to fetch managed objects for entity \(entity).")
        }
        return result
    }
}
