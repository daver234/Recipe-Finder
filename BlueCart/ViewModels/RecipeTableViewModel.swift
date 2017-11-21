//
//  RecipeTableViewModel.swift
//  BlueCart
//
//  Created by David Rothschild on 11/8/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import UIKit
import CoreData
import Disk


/// ViewModel to support RecipeTableVC
class RecipeTableViewModel {
    
    // MARK: - Properties
    var didGetRecipes: Box<Bool> = Box(false)
    var recipePageNumber: Box<Int> = Box(0)
    var searchString: Box<String> = Box("")
    fileprivate(set) var searchTerms: Box<[NSManagedObject]> = Box([])
    var networkReachable = true
}


// MARK: - Functions to access the DataManager singleton
extension RecipeTableViewModel {
    func getRecipeCount() -> Int? {
        return DataManager.instance.totalRecipesRetrieved
    }
    
    func getRecipe(pageToGet: Int, recipeToGet: Int) -> Recipe {
        guard let recipe = DataManager.instance.allRecipes[pageToGet].recipes?[recipeToGet] else {
            return Recipe()
        }
        return recipe
    }
    
    func getPagesRetrieved() -> Int {
        return DataManager.instance.numberOfPagesRetrieved
    }
    
    func getRecipes(pageNumber: Int) -> [Recipe] {
        guard let recipes = DataManager.instance.allRecipes[pageNumber - 1].recipes else { return [Recipe]() }
        return recipes
    }
    
    /// Change network reachable status
    func isNetworkReachable(reachable: Bool) {
        networkReachable = reachable
    }
    
    /// Load search terms for accessing recipe pages
    /// RecipeTableVC then gets individual search terms from view model
    func loadSearchTerms() {
        retrievedSavedSearchTerms()
    }
    
    /// This function loads more recipes for the existing search term as the user scrolls the table view
    func loadRecipesForExistingSearchTerm(pageNumber: Int) {
        loadRecipes(pageNumber: pageNumber, searchString: searchString.value)
    }
    
    /// This function loads different recipes based on whether or not the device is online or offline.
    /// If offline, then retrieve saved recipes.  If online, do search.
    func loadRecipesBasedOnSearchTerm(searchString: String) {
        if networkReachable {
            loadRecipes(pageNumber: recipePageNumber.value, searchString: searchString) 
        } else {
            DataManager.instance.retrieveSavedSearchTermResults(term: searchString) { [weak self] success in
                if success {
                    self?.didGetRecipes.value = true
                }
            }
        }
        
    }
    
    /// Function for RecipeTableVC to save a new search term
    /// Then go get those recipes to display in table view
    /// - Parameter term:  The search term to save and find recipes
    func saveSearchTerm(term: String) {
        saveSearchTermToCoreData(term: term)
        loadRecipesBasedOnSearchTerm(searchString: term)
    }
}


// MARK: - CoreData Functions
extension RecipeTableViewModel {
    
    /// Saving search terms to CoreData
    /// Handles iOS 10 and above one way and iOS 9 and below another
    /// - Parameter term: The search term to save
    fileprivate func saveSearchTermToCoreData(term: String) {
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
    fileprivate func retrievedSavedSearchTerms() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.SEARCH_ENTITY)
            let sort = NSSortDescriptor(key: Constants.SEARCH_DATE, ascending: false)
            fetchRequest.sortDescriptors = [sort]
            do {
                searchTerms.value = []
                searchTerms.value = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
        } else {
            // Fallback on earlier versions of iOS
            let managedContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.SEARCH_ENTITY) //<NSManagedObject>(entityName: Constants.SEARCH_ENTITY)
            let entityDesc = NSEntityDescription.entity(forEntityName: Constants.SEARCH_ENTITY, in: managedContext)
            fetchRequest.entity = entityDesc
            do {
                guard let tempSearchTerms = try managedContext.fetch(fetchRequest) as? [NSManagedObject] else { return  }
                searchTerms.value = tempSearchTerms
            } catch {
                print("Could not fetch. \(error)")
            }
        }
    }
}


// MARK: - Functions for accessing backend server
extension RecipeTableViewModel {
    /// Primary function to get RecipePage from backend
    /// Used on app launch, search terms, and prefetching more table rows
    func loadRecipes(pageNumber: Int, searchString: String) {
        let apiManager = getAPIManagerInstance()
        apiManager.getRecipesForPage(pageNumber: pageNumber, searchString: searchString) { [weak self] success in
            if success {
                self?.recipePageNumber.value += 1
                self?.didGetRecipes.value = true
            }
        }
    }
    
    fileprivate func getAPIManagerInstance() -> APIManager {
        let request = Request()
        return APIManager(request: request)
    }
}
