//
//  RecipeTableVC.swift
//  BlueCart
//
//  Created by David Rothschild on 11/6/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftSpinner
import Reachability
import ModalStatus


class RecipeTableVC: UIViewController, UITableViewDataSourcePrefetching, UISearchResultsUpdating {
    
    // MARK: - Properties
    let searchController = UISearchController(searchResultsController: nil)
    let reachability = Reachability()!
    var viewModel = RecipeTableViewModel()
    var filteredSearchTerms = [String]()
    var searchTerms = [String]()
    let isAppStart = true
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Identifier used for unit testing
        view.accessibilityIdentifier = Constants.RECIPE_TVC_UITEST
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
        viewModel.currentSearchString.value = ""
        viewModel.loadRecipesBasedOnSearchTerm(searchString: viewModel.currentSearchString.value)
        
        /// Load search terms from Core Data for use when user is searching terms
        viewModel.loadSearchTerms()
        startSpinner(term: "you")
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
        searchController.searchBar.barTintColor = ColorPalette.Green.Light
        
        /// To get Cancel button to be black when search bar is present
        let cancelButtonAttributes: [NSAttributedStringKey: UIColor] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.black]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelButtonAttributes, for: .normal)
        searchController.searchBar.borderWidth = 1
        searchController.searchBar.borderColor = ColorPalette.Green.Light
    }
    
    /// Monitor any required properties from view model and perform actions on change.
    func monitorProperties() {
        /// Bool to indicate if new recipes were retrieved.  If so, reload data.
        /// Also, start spinner if this is first app launch. 
        viewModel.didGetRecipes.bind { [unowned self] (isNewRecipe) in
            guard !isNewRecipe else {
                self.reloadAfterRecipesChanged()
                return
            }
            guard self.isAppStart else {
                self.reloadAfterRecipesChanged()
                return
            }
            self.startSpinner(term: "you")
        }
    }
    
    /// Reset these items when new recipes arrive.
    func reloadAfterRecipesChanged() {
        DispatchQueue.main.async {
            self.setupNavBarTitle()
            SwiftSpinner.hide()
            self.tableView.reloadData()
        }
    }
    
    /// Set up navigation bar
    func setupNavBarTitle() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 240, height: 44))
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 0
        label.font = UIFont(name: Constants.AVENIR_HEAVY, size: 15)
        label.textAlignment = NSTextAlignment.center
        let results = DataManager.instance.totalRecipesRetrieved
        label.text = "Search For Recipes\nFound \(results) Results"
        self.navigationItem.titleView = label
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = ColorPalette.Green.Light
        
        ///  The following is to get rid of the 1px line at the bottom of the Navigation Bar
        navigationController?.navigationBar.setBackgroundImage(UIImage.imageWithColor(color: ColorPalette.Green.Light), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage.imageWithColor(color: ColorPalette.Green.Light)
    }
    
    /// Check for device online or offline.
    /// If offline, get data from local CoreData rather than server.
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
            viewModel.isNetworkReachable(reachable: true)
            loadInitialRecipePage()
        case .cellular:
            print("Reachable via Cellular")
            viewModel.isNetworkReachable(reachable: true)
            loadInitialRecipePage()
        case .none:
            TableViewHelper.EmptyMessage(message: Constants.NO_NET_MESSAGE, viewController: self, tableView: tableView)
            print("Network not reachable")
            viewModel.isNetworkReachable(reachable: false)
            loadInitialRecipePage()
        }
    }
}

// MARK: - Navigation
extension RecipeTableVC {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch isSearchBarActive() {
        case true:
            guard let indexPath = tableView.indexPathForSelectedRow,
                let currentCell = tableView.cellForRow(at: indexPath) as? RecipeTableViewCell,
                let term = currentCell.recipeTitleLabel.text else { return }
            
            /// Set the active search term in the view model
            let newString : String
            term == Constants.TOP_RATED ? (newString = "") : (newString = term)
            viewModel.currentSearchString.value = newString
            if term == Constants.TOP_RATED {
                viewModel.loadRecipesBasedOnSearchTerm(searchString: "")
                searchController.isActive = false
            } else {
                // searchController.isActive = false
                viewModel.loadRecipesBasedOnSearchTerm(searchString: term)
                
            }
            startSpinner(term: term)
        case false:
            switch segue.destination {
            case is DetailPageViewController:
                guard let destination = segue.destination as? DetailPageViewController else { return }
                guard let indexPath = tableView.indexPathForSelectedRow?.row else { return }
                let sendRecipe = getRecipe(index: indexPath)
                destination.recipeFromTable = sendRecipe
                destination.isReachable = viewModel.networkReachable
                destination.indexFromAllRecipesWithoutPages = indexPath
            default:
                break
            }
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
