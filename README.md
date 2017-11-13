# Recipe Finder
![alt text](Recipes.png "Choose recipe")
![alt text](recipeDetail.png "Detail of the recipe")
![alt text](searchTerms.png "Search term history")

## Overview

The purpose of this app is to help someone find a recipe.

Upon starting the app, you are presented with a table of top rated recipes in descending order.  As you scroll, the table loads more recipes.  Tapping on a recipe cell segues to the detail of the recipe.  Tapping on the search bar, allows searching for new recipes based on the search terms entered.

Key Features:
- Show top rated recipes
- Show details of recipe including ingredients
- Check mark next to each ingredient to check off after use when making recipe
- Find new recipes based on search terms
- View history of previous search terms, tap to reload
- Check for network connection.  If no network, display message.
- View previous recipe search results offline. (but not individual recipes)
- Support for iOS 9 and above.


## Comments on Each Screen
* **Top Rated**  When you first launch, the top rated recipes are shown.  Scroll to load more.
* **Recipe Detail**  Here is the detail of the recipe.  It also loads the ingredients and adds a checkbox next to each ingredient so the user can check the ingredient after it has been used in the recipe.  The check mark does not persist. If you load the recipe again, the check marks will be empty.  Perhaps persistence could be added.
* **Search Terms**  Tap on the search bar to enter a new search term. Or select from a previous search by tapping on the search term. The search terms are sorted for the most recent search first. But Top Rated is always listed on the top when you are are online.  The keyboard does not display while in the searchbar controller and while the phone is offline.  We don't want the user to enter new search terms offline.


## Architecture
MVC and MVVM
Swift 4
CoreData for iOS 9 and above
...add design diagram
....more to come

## Offline
If no cellular or WiFi is detected, no results will be shown on launch but a message will appear asking the user to tap in the search bar to get a list of previous searches.  Then by tapping on any of those search terms, a list of 30 recipes from that search term will appear.  It is limited to 30 right now.  Tap the search bar again and load one of the other search terms, all offline.  The images are stored offline as well using Kingfisher.

## CoreData
The search terms are store and retrieved in CoreData.  Support is there for CoreData in iOS9 and above.  Apple changed how CoreData works in iOS 10 (maybe iOS 9.1?).  The offline list of 30 recipes is stored using the Disk framework into the local cache storage.  With further work, perhaps this could be stored in CoreData.  Right now, the CoreData stack code is in the AppDelegate but probably should be moved out into a separate class.

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
5. Disk - A framework to persist structs, images and data.  https://github.com/saoudrizwan/Disk

No need to run the Podfile as the pods are checkin.  As of November 12, the M13Checkbox pod has a bug in the M13Checkbox.swift file.  Without changing a line of code, you will only see one check box needs to one of the list of ingredients.  The fix is in the checked in Pod.  The fix is to change line 218 in the M13Checkbox.swift file like this:
```
//fileprivate var controller: M13CheckboxController = DefaultValues.controller
fileprivate var controller: M13CheckboxController = M13CheckboxStrokeController()
```



## Implementation Highlights:

* Swift 4 Decodable Protocol for parsing JSON from the server.
* Networking with URLSession broken down into single responsibility classes.
* Singleton for the data model. Simple struct data model.
* Using Storyboard
* Lazy loading of data source object using prefetch rows so data is ready as user scrolling approaches those cells.
* Caching of images for better performance.  Loading of a default image while network requests underway.
* Separate utilities for colors, constants and reachability.
* Cell configuration in cell class not view controller.
* MVVM architecture for shrinking size of ViewControllers and separating data management from the view controllers into the views.
* ...

---

Additional Work To Do
* Unit and UI tests
* Continue working on documentation
* Improve offline. Perhaps store more than 30
* Perhaps add Top Rated recipes to offline
* Add offline for individual recipes
* Delete search terms from table view
* Further testing
* Testing on iOS 9 and iOS 10
* CoreData testing on iOS 9
* Separate the CoreData stack from the AppDelegate
* Test and adjust for iPad, landscape and different screen sizes. Development was done primarily on a iPhone 7 Plus device and simulator and a iPhone 6 device. All other variants need testing.
* Look for refactoring and code clean up opportunities
* Additional inline code documentation
* ...


Copyright Dave Rothschild November 2017. Not for commercial use.
