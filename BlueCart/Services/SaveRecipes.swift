//
//  SaveRecipes.swift
//  BlueCart
//
//  Created by David Rothschild on 11/16/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import Foundation
import Disk

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
}
