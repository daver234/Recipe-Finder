//
//  RecipeTableViewModel.swift
//  BlueCart
//
//  Created by David Rothschild on 11/8/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import UIKit
import CoreData

/// ViewModel to support RecipeTableVC
class RecipeTableViewModel {
    
    // MARK: - Properties
    var didGetRecipes: Box<Bool> = Box(false)
    var recipePageNumber: Box<Int> = Box(0)
    fileprivate(set) var flatAllRecipes = [Recipe]()
    fileprivate(set) var searchTerms: [NSManagedObject] = []
}


/// Functions to access the DataManager singleton
extension RecipeTableViewModel {
    func getRecipeCount() -> Int? {
        return DataManager.instance.totalRecipesRetrieved
    }
    
    func getAllRecipesWithoutPages() -> [Recipe] {
        return DataManager.instance.allRecipesWithoutPages
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
        guard let recipes = DataManager.instance.allRecipes[pageNumber].recipes else { return [Recipe]() }
        return recipes
    }
    
    func incrementPageNumber() {
        recipePageNumber.value += 1
    }
    
    func getSearchTerms() -> [NSManagedObject] {
        retrievedSavedSearchTerms()
        print("viewModel search terms", searchTerms)
        return searchTerms
    }
    
    /// Saving search terms to CoreData
    /// Handles iOS 10 and above one way and iOS 9 and below another
    /// - Parameter term: The search term to save
    func saveSearchTerm(term: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        if #available(iOS 10.0, *) {
            // let task = Search(context: CoreDataStack.managedObjectContext)
            // task.searchTerms = term
            let managedContext = appDelegate.persistentContainer.viewContext
            guard let entity = NSEntityDescription.entity(forEntityName: Constants.SEARCH_ENTITY, in: managedContext) else { return }
            let searchTerm = NSManagedObject(entity: entity, insertInto: managedContext)
            searchTerm.setValue(term, forKey: Constants.SEARCH_TERMS)
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
            //let task = Search(entity: entityDesc!, insertInto: CoreDataStack.managedObjectContext)
            //task.searchTerms = term
        }
        
//        print("Now saving in CoreData")
//        CoreDataStack.saveContext()
    }
    
    func retrievedSavedSearchTerms() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        if #available(iOS 10.0, *) {
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.SEARCH_ENTITY)
//            let managedContext = CoreDataStack.managedObjectContext
//            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.SEARCH_ENTITY)
            do {
                searchTerms = try managedContext.fetch(fetchRequest)
                print("searchTerms", searchTerms)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
        } else {
            // Fallback on earlier versions of iOS
            let managedContext = appDelegate.managedObjectContext
//            let managedContext = CoreDataStack.managedObjectContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.SEARCH_ENTITY) //<NSManagedObject>(entityName: Constants.SEARCH_ENTITY)
            let entityDesc = NSEntityDescription.entity(forEntityName: Constants.SEARCH_ENTITY, in: managedContext)
            fetchRequest.entity = entityDesc
            do {
                 let result = try managedContext.fetch(fetchRequest)
                print("here is result", result)
            } catch {
                print("Could not fetch. \(error)")
            }
            
        }
    }
}


/// Functions for accessing backend server
extension RecipeTableViewModel {
    func loadRecipes(pageNumber: Int) {
        let request = Request()
        let apiManager = APIManager(request: request)
        apiManager.getRecipesForPage(pageNumber: pageNumber) { [weak self] success in
            if success {
                self?.recipePageNumber.value += 1
                self?.didGetRecipes.value = true
            }
        }
    }
    
//    func loadNewRecipesFromSearchText(searchTerm: String) {
//        print("Search term is:", searchTerm)
//    }
}
