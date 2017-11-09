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

struct Constants {
    
    // URLs
    static let SEARCH_URL = "http://food2fork.com/api/search/?key="
    static let RECIPE_URL = "http://food2fork.com/api/get"
    static let SCHEME = " http"
    static let HOST = "food2fork.com"
    static let PATH = "/api/search/?key=\(APIKeyService.API_KEY)"
    
    // Cell identifiers
    static let RECIPE_CELL = "RecipeCell"
    
    // Segues
    static let TO_RECIPE_DETAIL = "toRecipeDetail"
    
    // Other
    static let PAGE_SIZE = 30
    
    // Data
    var food = [
    Food(category:"Chocolate", name:"Chocolate Bar"),
    Food(category:"Chocolate", name:"Chocolate Chip"),
    Food(category:"Chocolate", name:"Dark Chocolate"),
    Food(category:"Hard", name:"Lollipop"),
    Food(category:"Hard", name:"Candy Cane"),
    Food(category:"Hard", name:"Jaw Breaker"),
    Food(category:"Other", name:"Caramel"),
    Food(category:"Other", name:"Sour Chew"),
    Food(category:"Other", name:"Gummi Bear"),
    Food(category:"Other", name:"Candy Floss"),
    Food(category:"Chocolate", name:"Chocolate Coin"),
    Food(category:"Chocolate", name:"Chocolate Egg"),
    Food(category:"Other", name:"Jelly Beans"),
    Food(category:"Other", name:"Liquorice"),
    Food(category:"Hard", name:"Toffee Apple")
    ]
    
}
