//
//  Constants.swift
//  BlueCart
//
//  Created by David Rothschild on 11/6/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import Foundation

// Typealias
typealias CompletionHandler = (_ Success: Bool) -> ()
typealias CompletionHandlerWithData = (_ recipeDetail: [String: RecipeDetail]?, _ error: Error?) -> ()

struct Constants {
    
    // URLs
    static let SEARCH_URL = "http://food2fork.com/api/search/?key="
    static let RECIPE_URL = "http://food2fork.com/api/get/?key="
    static let SCHEME = " http"
    static let HOST = "food2fork.com"
    static let PATH = "/api/search/?key=\(APIKeyService.API_KEY)"
    
    // URL parameters
    static let SEARCH_QUERY = "q"       // Search query; separate ingredients by commas
    static let RECIPE_ID = "rId"        // ID of receipe for search query
    static let SORT_BY_RATING = "r"       // Social media ratings
    static let SORT_BY_TRENDING = "t"     // Trend score
    
    // Cell identifiers
    static let RECIPE_CELL = "RecipeCell"
    static let INGREDIENTS = "Ingredients"
    static let SEARCH_CELL = "SearchBarVCCell"
    
    // Segues
    static let TO_RECIPE_DETAIL = "toRecipeDetail"
    
    // Other
    static let PAGE_SIZE = 30
    static let LOADING_IMAGE = "loadingImage.jpg"
    static let RECIPE_TITLE = "Recipe"
    static let SEARCHBAR_PLACEHOLDER = "Search for recipes..."
    
    // CoreData
    static let SEARCH_TERMS = "searchTerms"  // attribute name for store search terms
    static let SEARCH_DATE = "createdAt"  // attribute for date term was created
    static let SEARCH_ENTITY = "Search" // Search entity
    
    // Controllers
    static let SEARCH_VC = "SearchBarVC"
    
    // Search Terms
    static let TOP_RATED = "Top Rated"
    static let RECIPE_DETAIL = "recipeDetail"
    
    // Fonts
    static let AVENIR_HEAVY = "Avenir-Heavy"
    static let AVENIR = "Avenir"
    
    // Messages
    static let NO_NET_MESSAGE = "It appears you do not have a network connection. Tap in the Search Bar to select and view a previous search offline."
    
    // File names
    static let TOP_RATED_FILE = "toprated"
    static let RECIPE_DETAIL_FILE = "recipedetail"
    
    // Accessability Identifiers for UI Testing
    static let RECIPE_TVC_UITEST = "recipeTableVC"
}
