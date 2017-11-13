# Recipe Finder
![alt text](Recipes.png "Choose recipe")
![alt text](recipeDetail.png "Detail of the recipe")
![alt text](searchTerms.png "Search term history")

## Overview

The purpose of this app is to help someone find a recipe.

Upon starting the app, you are presented with a table of top rated recipes in descending order.  As you scroll, the table loads more recipes.  Tapping on a recipe cell segues to the detail of the recipe.  Tapping on the search bar, allows searching for new recipes based on the search terms entered.

Key Features:
- Show top rated recipes
- Find new recipes based on search terms
- View history of previous search terms, tap to reload
- Check for network connection.  If no network, display message and view previous search results offline.
- Support for iOS 9 and above.
- Portrait only?


## Comments on the Main View

TBD

* **Top Rated**  tbd.  
* **Recipe Detail**  tbd
* **Search Terms**  TBD


## Architecture

MVC and MVVM
Swift 4
....more to come

## Requriements

* You need iOS 9 or above.  
* You need a API Key from Food2Fork.com.  Implement a struct similar to this:
```
  struct APIKeyService {
    static let API_KEY = "your api key"
  }
```

## Installation of Pods
### Included Libraries via Pods
1. M13Checkbox - for a check mark in next to ingredients in DeailView. https://github.com/Marxon13/M13Checkbox
2. Kingfisher - for image downloading, caching and management. https://github.com/onevcat/Kingfisher
3. Reachability by Ashley Mills - to handle checking for a network connection and if not there redirecting the user to Settings. https://github.com/ashleymills/Reachability.swift
4. SwiftSpinner - A very nice spinner.  I use it here for to let the user know the data is still loading.  A much nicer approach than the activity indicator in iOS. https://github.com/icanzilb/SwiftSpinner

No need to run the Podfile as the pods are checkin.  As of November 12, the M13Checkbox pod has a bug in the M13Checkbox.swift file.  Without changing a line of code, you will only see one check box needs to one of the list of ingredients.  The fix is in the checked in Pod.  The fix is to change line 218 in the M13Checkbox.swift file like this:
```
//fileprivate var controller: M13CheckboxController = DefaultValues.controller
fileprivate var controller: M13CheckboxController = M13CheckboxStrokeController()
```



## Implementation Highlights:

* Swift 4 Decodable Protocol for parsing JSON from the server.
* Networking with URLSession broken down into single responsibility classes.
* Singleton for the data model. Simple struct data model.
* **** Unit and UI tests with live and mock data tests.
* Using Storyboard
* Lazy loading of data source object using prefetch rows so data is ready as user scrolling approaches those cells.
* Caching of images for better performance.  Loading of a default image while network requests underway.
* Separate utilities for colors, constants and reachability.
* Cell configuration in cell class not view controller.
* MVVM architecture for shrinking size of ViewControllers and separating data management from the view controllers into the views.

---

Attributions
* TBD


Copyright Dave Rothschild November 2017
