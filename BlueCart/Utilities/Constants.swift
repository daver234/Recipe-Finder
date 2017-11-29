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
typealias CompletionHandlerWithData = (_ recipeDetail: [String: Recipe]?, _ error: Error?) -> ()
typealias CompletionHandlerWithRecipes = (_ recipes: [Recipe]?, _ error: Error?) -> ()

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
    static let TO_PAGE_CONTROLLER = "toPageController"
    
    // Storyboard identifiers
    static let RECIPE_DETAIL_SB = "RecipeDetail"
    
    // Other
    static let PAGE_SIZE = 30
    static let LOADING_IMAGE = "loadingImage.jpg"
    static let RECIPE_TITLE = "Recipe"
    static let SEARCHBAR_PLACEHOLDER = "Search for recipes..."
    
    // CoreData for Search
    static let SEARCH_TERMS = "searchTerms"  // attribute name for store search terms
    static let SEARCH_DATE = "createdAt"  // attribute for date term was created
    static let SEARCH_ENTITY = "Search" // Search entity
    
    // CoreData attributes RecipePage
    static let MRECIPE_PAGE = "MRecipePage" // RecipePage entity
    static let MPAGE_NUMBER = "mPageNumber"
    static let MCREATED_AT_PAGE = "mCreatedAt"
    static let MCOUNT = "mCount"
    static let MSEARCH_TERM = "mSearchTerm"
    static let MRECIPES = "mRecipes"
    
    // CoreData attributes RecipeDetail
    static let MRECIPE_DETAIL = "MRecipeDetail"  // Recipe entity
    static let MCREATED_AT_RECIPE = "mCreatedAt"
    static let MIMAGE_URL = "mImageUrl"
    static let MINGREDIENTS = "mIngredients"
    static let MPUBLISHER = "mPublisher"
    static let MPUBLISER_URL = "mPublisherUrl"
    static let MRECIPE_ID = "mRecipeID"
    static let MSOCIAL_RANK = "mSocialRank"
    static let MSOURCE_URL = "mSourceUrl"
    static let MTITLE = "mTitle"
    static let MURL = "mUrl"
    static let MSEARCH_TERM_DETAIL = "mSearchTerm"
    
    // Controllers
    static let SEARCH_VC = "SearchBarVC"
    
    // Search Terms
    static let TOP_RATED = "Top Rated"
    static let TOP_RATED_LOWER = "toprated"
    static let RECIPE_DETAIL = "recipeDetail"
    
    // Fonts
    static let AVENIR_HEAVY = "Avenir-Heavy"
    static let AVENIR = "Avenir"
    
    // Messages
    static let NO_NET_MESSAGE = "It appears you do not have a network connection. Tap in the Search Bar to select and view a previous search offline."
    static let NO_INGREDIENTS = "You have to first view this recipe while online before ingredients are available offline."
    
    // File names
    static let TOP_RATED_FILE = "toprated"
    static let RECIPE_DETAIL_FILE = "recipedetail"
    
    // Accessability Identifiers for UI Testing
    static let RECIPE_TVC_UITEST = "recipeTableVC"
}
