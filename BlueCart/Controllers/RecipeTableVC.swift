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
    private var viewModel = RecipeTableViewModel()
    var filteredSearchTerms = [String]()
    var searchTerms = [String]()
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Identifier used for unit testing
        view.accessibilityIdentifier = Constants.RECIPE_TVC_UITEST
        
        loadInitialRecipePage()
        setupNavBarTitle()
        setupSearchBar()
        monitorProperties()
        tableView.delegate = self
        tableView.dataSource = self
        searchController.searchBar.delegate = self
        startSpinner(term: "you")
        if #available(iOS 10.0, *) {
            self.tableView.prefetchDataSource = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.setNeedsLayout()
            self.tableView.layoutIfNeeded()
            self.tableView.reloadData()
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
    
    func loadInitialRecipePage() {
        /// On app launch, the searchString should be empty, meaning "", to cause
        /// the API to load Top Rated recipes....per API docs.
        /// And we always start by loading page 1.  When scrolling (iOS 10 and above) more pages load
        /// via the prefetching API
        viewModel.searchString.value = ""
        viewModel.loadRecipes(pageNumber: 1, searchString: viewModel.searchString.value)
        
        /// Load search terms from Core Data for use when user is searching terms
        viewModel.loadSearchTerms()
    }
    
    func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.returnKeyType = .search
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.autocorrectionType = .yes
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        } else {
            searchController.dimsBackgroundDuringPresentation = false
        }
        searchController.searchBar.placeholder = Constants.SEARCHBAR_PLACEHOLDER
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
    }
    
    func monitorProperties() {
        /// When page number increments, more data is available so reload the tableView
        viewModel.recipePageNumber.bind { [unowned self] (value) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        /// Bool to indicate if new recipes were retrieved.  If so, reload data.
        viewModel.didGetRecipes.bind { [unowned self] (isNewRecipe) in
            if isNewRecipe {
                DispatchQueue.main.async {
                    self.setupNavBarTitle()
                    SwiftSpinner.hide()
                    self.tableView.reloadData()
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
            viewModel.isNetworkReachable(reachable: true)
        case .cellular:
            print("Reachable via Cellular")
            viewModel.isNetworkReachable(reachable: true)
        case .none:
            TableViewHelper.EmptyMessage(message: Constants.NO_NET_MESSAGE, viewController: self, tableView: tableView)
            print("Network not reachable")
            viewModel.isNetworkReachable(reachable: false)
        }
    }
}


// MARK: - Prefetch data for tablevView
extension RecipeTableVC {
    
    /// Here we prefetch the images for the tableview using Kingfisher.
    /// And, prefetch more data if the user is getting to the end of the tableview.
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        /// First get the images
        let currentPage = viewModel.getPagesRetrieved()
        let recipes = viewModel.getRecipes(pageNumber: currentPage)
        var stringToUrl = [URL]()
        for item in recipes {
            guard let stringUrl = item.imageUrl, let url = URL(string: stringUrl) else { return }
            stringToUrl.append(url)
        }
        let urls = stringToUrl.flatMap { $0 }
        ImagePrefetcher(urls: urls).start()
        
        /// This section is for prefetching more data before the user gets to the end of the tableview with the current data
        /// First, build an array of all the upcoming rows.
        let upcomingRows = indexPaths.map { $0.row }
        
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
        let nextPage: Int = ((maxIndex + 5) / Constants.PAGE_SIZE) + 1

        /// If the user is getting to the end of the table, nextPage will be greater than current page.
        /// This will then trigger a API call to get more data from the server and return, ideally, before
        /// the user gets to the end of the table. The active search string is also included so that
        /// the right set of recipes load.
        if nextPage > currentPage {
            viewModel.loadRecipes(pageNumber: nextPage, searchString: viewModel.searchString.value)
        }
    }
}

// MARK: - Table view data source
extension RecipeTableVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    /// Load different data sets depending on status of search bar and if text has been entered
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch isSearchBarActive() {
        case true:
            switch searchBarIsEmpty() {
            case true:
                return searchTerms.count + 1
            case false:
                return filteredSearchTerms.count + 1
            }
        case false:
            searchController.searchBar.isHidden = false
            return viewModel.getRecipeCount() ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.RECIPE_CELL, for: indexPath) as? RecipeTableViewCell else {
           return UITableViewCell()
        }
        switch isSearchBarActive() {
        case true:
            var termString : String
            // First add Top Rated to search term list
            if indexPath.row == 0 {
                termString = Constants.TOP_RATED
                cell.setupViewForIndexZero(searchTerm: termString)
                return cell
            } else {
                switch searchBarIsEmpty() {
                case true:
                    termString = searchTerms[indexPath.row - 1]
                case false:
                    termString = filteredSearchTerms[indexPath.row - 1]
                }
            }
            cell.setupViewIfCoreData(searchTerm: termString)
        case false:
            let specificRecipe = getRecipe(index: indexPath.row)
            cell.setupView(recipe: specificRecipe)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchController.isActive {
            return 35
        } else {
            return 150
        }
    }
    
    /// Get a specific recipe.  Used with setting up tableViewCell
    func getRecipe(index: Int) -> Recipe {
        let recipe: Recipe
        /// Find the page with the receipt for the cell
        let pageToGet = index / Constants.PAGE_SIZE
        
        /// To get the receipt number within a page of recipes, just need
        /// the modulus of row to page size
        let recipeToGet = index % Constants.PAGE_SIZE
        
        recipe = viewModel.getRecipe(pageToGet: pageToGet, recipeToGet: recipeToGet)
        return recipe
    }
}


// MARK: - Navigation
extension RecipeTableVC {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch isSearching() {
        case true:
            print("Don't segue since the search terms are displaying.")
        case false:
            if segue.identifier == Constants.TO_RECIPE_DETAIL {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let sendRecipe = getRecipe(index: indexPath.row)
                
                    // Send selected recipe to the RecipeDetailVC
                    guard let destination = segue.destination as? RecipeDetailVC else { return }
                    destination.recipeFromTable = sendRecipe
                    destination.isReachable = viewModel.networkReachable
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch isSearching() {
        case true:
            guard let indexPath = tableView.indexPathForSelectedRow,
                let currentCell = tableView.cellForRow(at: indexPath) as? RecipeTableViewCell,
                let term = currentCell.recipeTitleLabel.text
            else { return }
            /// Set the active search term in the view model
            viewModel.searchString.value = term
            viewModel.recipePageNumber.value = 0
            if term == Constants.TOP_RATED {
                viewModel.loadRecipesBasedOnSearchTerm(searchString: "")
            } else {
                viewModel.loadRecipesBasedOnSearchTerm(searchString: term)
            }
            startSpinner(term: term)
        case false:
            self.performSegue(withIdentifier: Constants.TO_RECIPE_DETAIL, sender: self)
        }
    }
    
    /// Start spinner to cover for time to make network requests
    func startSpinner(term: String) {
        SwiftSpinner.setTitleFont(UIFont(name: "Avenir-Heavy", size: 22.0))
        SwiftSpinner.sharedInstance.innerColor = UIColor.green.withAlphaComponent(0.5)
        SwiftSpinner.show("Getting recipes\nfor \(term)...")
        searchController.isActive = false
    }
}


// MARK: - Search
extension RecipeTableVC: UISearchBarDelegate {
    
    /// Function to get saved searched terms from CoreData
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        viewModel.loadSearchTerms()
        searchTerms = []
        convertManagedSearchTermsToArray()
        tableView.backgroundView = UIView(frame: .zero)
        if reachability.connection == .none {
            searchBar.enablesReturnKeyAutomatically = false
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    /// Convert search terms from managed objects to a string array.
    /// This is used for filtering while the user is typing in the search bar
    func convertManagedSearchTermsToArray() {
        for term in viewModel.searchTerms.value {
            guard let searchTermString = term.value(forKey: Constants.SEARCH_TERMS) as? String else { return }
            searchTerms.append(searchTermString)
        }
        // filteredSearchTerms = searchTerms
        print("filteredSearchTerms: ", filteredSearchTerms)
    }
    
    /// Save search text to CoreData
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchText = searchController.searchBar.text else { return }
        viewModel.saveSearchTerm(term: searchText)
        startSpinner(term: searchText)
    }
    
    // Filter search text entry
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        tableView.reloadData()
    }
    
    /// If search bar is active means user has clicked on it
    func isSearchBarActive() -> Bool {
        return searchController.isActive ? true : false
    }
    
    /// Returns true if the text is empty or nil
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    /// Returns true if focus in searchbar
    func isSearching() -> Bool {
        return searchController.isActive ? true : false
    }
    
    /// As the user types adjust the data source to match what reamins
    /// in the searchTerms array
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredSearchTerms = searchTerms.filter( { (text: String) -> Bool in
            return text.contains(searchText.lowercased())
        })
    }
}
