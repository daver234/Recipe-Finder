//
//  RecipeTableVC.swift
//  BlueCart
//
//  Created by David Rothschild on 11/6/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import UIKit
import Kingfisher
import CoreData
import SwiftSpinner
import Reachability

class RecipeTableVC: UIViewController, UITableViewDataSourcePrefetching, UISearchResultsUpdating {
    
    // MARK: - Properties
    let searchController = UISearchController(searchResultsController: nil)
    let reachability = Reachability()!
    var didShowNoNetworkMessage = false
    
    
    private var viewModel = RecipeTableViewModel()
    var searchTerms: [NSManagedObject] = []
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadRecipes(pageNumber: 0)
        setupNavBarTitle()
        setupSearchBar()
        monitorProperties()
        tableView.delegate = self
        tableView.dataSource = self
        searchController.searchBar.delegate = self
        if #available(iOS 10.0, *) {
            self.tableView.prefetchDataSource = self
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// Watch for connectivity being turned off
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
        
        /// Allows user to see what cell they came from after returning from ReceiptDetailVC
        /// This uses the UITableView extension in Extensions.swift
        self.tableView.deselectSelectedRow(animated: true)
        tableView.reloadData()
    }
    func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.returnKeyType = .search
        // searchController.hidesNavigationBarDuringPresentation = false
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        } else {
            searchController.dimsBackgroundDuringPresentation = false
        }
        searchController.searchBar.placeholder = "Search for recipes..."
        
        //if #available(iOS 11.0, *) {
        //    navigationItem.searchController = searchController
        //} else {
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
        //}
        definesPresentationContext = true
        // searchBar.returnKeyType = UIReturnKeyType.search
    }
    
    func monitorProperties() {
        /// When page number increments, more data is available so reload the tableView
        viewModel.recipePageNumber.bind { [unowned self] (value) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        viewModel.didGetRecipes.bind { [unowned self] (isNewRecipe) in
            if isNewRecipe {
                DispatchQueue.main.async {
                    self.setupNavBarTitle()
                    // self.filteredRecipe = self.viewModel.getAllRecipesWithoutPages()
                }
            }
        }
    }
    
    func setupNavBarTitle() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 240, height: 44))
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 0
        label.font = UIFont(name: Constants.AVENIR_HEAVY, size: 15)
        label.textAlignment = NSTextAlignment.center
        let results = DataManager.instance.totalRecipesRetrieved
        label.text = "Search For Recipes\nFound \(results) Results"
        self.navigationItem.titleView = label
    }
    
    /// Check for what state changed for connectivity
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
        case .cellular:
            print("Reachable via Cellular")
        case .none:
            TableViewHelper.EmptyMessage(message: Constants.NO_NET_MESSAGE, viewController: self, tableView: tableView)
            print("Network not reachable")
        }
    }
}


// MARK: - Prefetch data for tablevView
extension RecipeTableVC {
    /// Here we prefetch the images for the tableview using Kingfisher.
    /// And, prefetch more data if the user is getting to the end of the tableview.
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        /// First get the images
        let currentPage = viewModel.getPagesRetrieved() - 1
        let recipes = viewModel.getRecipes(pageNumber: currentPage)
        var stringToUrl = [URL]()
        for item in recipes {
            guard let stringUrl = item.imageUrl, let url = URL(string: stringUrl) else { return }
            stringToUrl.append(url)
        }
        // let stringToUrl = recipes { URL(string: $0) }
        let urls = stringToUrl.flatMap { $0 }
        ImagePrefetcher(urls: urls).start()
        
        /// This section is for prefetching more data before the user gets to the end of the tableview with the current data
        /// First, build an array of all the upcoming rows.
        let upcomingRows = indexPaths.map { $0.row }
        print("&&& here is upcoming rows", upcomingRows)
        
        /// Check to see what the max upcoming row number is
        if let maxIndex = upcomingRows.max() {
            fetchMoreData(maxIndex: maxIndex, currentPage: currentPage)
        }
    }
    
    /// Fetch more data if the user is getting to the end of the tableview
    func fetchMoreData(maxIndex: Int, currentPage: Int) {
        /// Here take maxIndex and add 5 to give some buffer for how soon we should get more data from the server.
        /// This will improve the user experience so no delay is perceived when scrolling the table.
        /// All of this determines the nextPage to get
        let nextPage: Int = ( (maxIndex + 5) / Constants.PAGE_SIZE)

        /// If the user is getting to the end of the table, nextPage will be greater than current page.
        /// This will then trigger a API call to get more data from the server and return, ideally, before
        /// the user gets to the end of the table.
        if nextPage > currentPage {
            print("&&& in nextPage >", nextPage)
            print("&&& Here is current page", currentPage)
            print("&&& here is maxIndex", maxIndex)
            viewModel.loadRecipes(pageNumber: nextPage)
        }
    }
}

// MARK: - Table view data source
extension RecipeTableVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching() {
            print("count isSearch numRows", searchTerms.count)
            return searchTerms.count + 1
        }
        return viewModel.getRecipeCount() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.RECIPE_CELL, for: indexPath) as? RecipeTableViewCell else {
           return UITableViewCell()
        }
        
        switch isSearching() {
        case true:
            if indexPath.row == 0 {
                cell.setupViewIfCoreData(searchTerm: Constants.TOP_RATED)
            } else {
                let term = searchTerms[indexPath.row - 1]
                guard let searchTermString = term.value(forKey: Constants.SEARCH_TERMS) as? String else { return UITableViewCell() }
                cell.setupViewIfCoreData(searchTerm: searchTermString)
            }
        case false:
            let specificRecipe = getRecipe(index: indexPath.row)
            cell.setupView(recipe: specificRecipe)
        }
        return cell
    }
    
    /// This displays the "end of data" footer view when the user has scolled to the end of the available data.
    /// Because of the prefetching of data above, the user does not need to see a spinner when more data is loading.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            // tableFooterView.isHidden = false
            print("Here in willDisplay")
        }
    }
    
    /// Get search string out of ManagedObject
    /// - Parameter index: index of search string to retrieve from ManagedObject
    func searchStringFromManagedObject(index: Int) ->String {
        let term = searchTerms[index]
        guard let searchTermString = term.value(forKey: Constants.SEARCH_TERMS) as? String else { return ""}
        return searchTermString
    }
    
    /// Get a specific recipe.  Used with setting up tableViewCell
    func getRecipe(index: Int) -> Recipe {
        let recipe: Recipe
//        if isSearching() {
//            recipe = Recipe()
//            print("isSearching in getRecipe")
//        } else {
            /// Find the page with the receipt for the cell
            let pageToGet = index / Constants.PAGE_SIZE
            
            /// To get the receipt number within a page of recipes, just need
            /// the modulus of row to page size
            let recipeToGet = index % Constants.PAGE_SIZE
            
            recipe = viewModel.getRecipe(pageToGet: pageToGet, recipeToGet: recipeToGet)
        //}
        return recipe
    }
}


// MARK: - Navigation
extension RecipeTableVC {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch isSearching() {
        case true:
            print("do something")
        case false:
            if segue.identifier == Constants.TO_RECIPE_DETAIL {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let detailRecipe = getRecipe(index: indexPath.row)
                    guard let destination = segue.destination as? RecipeDetailVC else { return }
                    destination.recipeIdToGet = detailRecipe.recipeID
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch isSearching() {
        case true:
            print("did select row")
            guard let indexPath = tableView.indexPathForSelectedRow,
                let currentCell = tableView.cellForRow(at: indexPath) as? RecipeTableViewCell,
                var term = currentCell.recipeTitleLabel.text
            else { return }
            if term == Constants.TOP_RATED {
                term = ""
            }
            viewModel.getRecipesBasedOnSearchTerm(term: term)
            startSpinner(term: term)
        case false:
            self.performSegue(withIdentifier: Constants.TO_RECIPE_DETAIL, sender: self)
        }
    }
    
    /// Start spinner to cover for time to make network requests
    func startSpinner(term: String) {
        SwiftSpinner.setTitleFont(UIFont(name: "Avenir-Heavy", size: 22.0))
        SwiftSpinner.sharedInstance.innerColor = UIColor.green.withAlphaComponent(0.5)
        SwiftSpinner.show(duration: 2.0, title: "Getting recipes\nfor \(term)...", animated: true)
        searchController.isActive = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) { [weak self] in
            self?.tableView.reloadData()
        }
    }
}


// MARK: - Search
extension RecipeTableVC: UISearchBarDelegate {
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        // stNSObject.cancelPreviousPerformRequests(withTarget: self)  /// may delete this
//        guard let searchText = searchController.searchBar.text else { return }
//        
//        if searchText.isEmpty {
//            print("Search is empty")
//        } else {
//            // tableView.reloadData()
//            // perform(#selector(getRecipesBasedOnSearchText), with: nil, afterDelay: 2.0)
//        }
//    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // tableView.reloadData()
    }
    
    /// Function to get saved searched terms from CoreData
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchTerms = []
        searchTerms = viewModel.getSearchTerms()
        tableView.backgroundView = UIView(frame: .zero)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            self?.tableView.reloadData()
        }
        //tableView.reloadData()
    }
    
    /// Save search text to CoreData
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchText = searchController.searchBar.text else { return }
        viewModel.saveSearchTerm(term: searchText)
        startSpinner(term: searchText)
    }
    
//    @objc func getRecipesBasedOnSearchText() {
//        guard let searchText = searchController.searchBar.text else { return }
//        // viewModel.loadNewRecipesFromSearchText(searchTerm: searchText)
//        print("now in getRecipesBasedOnSearch", searchText)
//    }
    
    // MARK: - Functions to filter search text entry
    func updateSearchResults(for searchController: UISearchController) {
        tableView.reloadData()
        // filterContentForSearchText(searchController.searchBar.text!)
    }
    
    /// Returns true if focus in searchbar
    func isSearching() -> Bool {
        return searchController.isActive ? true : false
    }

    /// Returns true if text is empty or nil
//    func searchBarIsEmpty() -> Bool {
//        let test = searchController.searchBar.text?.isEmpty ?? true
//        print("searchBarisEmpty: ", test)
//        return searchController.searchBar.text?.isEmpty ?? true
//    }
//    
//    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
////        let recipes = viewModel.getAllRecipesWithoutPages()
////        filteredRecipe = recipes.filter( { (recipe: Recipe) -> Bool in
////            guard let recipe = recipe.title else { return false}
////            //print("recipe filter is: ", recipe)
////            //print("recipe lowercased", recipe.lowercased())
////            //print("contains:", recipe.lowercased().contains(text))
////            return recipe.lowercased().contains(searchText.lowercased())
////        })
//        tableView.reloadData()
//    }
}
