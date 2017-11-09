//
//  RecipeTableVC.swift
//  BlueCart
//
//  Created by David Rothschild on 11/6/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import UIKit

class RecipeTableVC: UIViewController {
    
    // MARK: - Properties
    var filteredData = [Food]()
    let searchController = UISearchController(searchResultsController: nil)
    private var viewModel = RecipeTableViewModel()
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadRecipes()
        setupNavBarTitle()
        setupSearchBar()
        monitorProperties()
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// Allows user to see what cell they came from after returning from ReceiptDetailVC
        /// This uses the UITableView extension in Extensions.swift
        self.tableView.deselectSelectedRow(animated: true)
        
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
        viewModel.recipePageNumber.bind { [unowned self] (value) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func setupNavBarTitle() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 240, height: 44))
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 0
        label.font = UIFont(name: "Avenir-Heavy", size: 15)
        label.textAlignment = NSTextAlignment.center
        label.text = "Search For Recipes\nFound X Results"
        self.navigationItem.titleView = label
    }
}


// MARK: - Table view data source
extension RecipeTableVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if isSearching() {
//            return filteredData.count
//        }
//        print("count is: ", Constants().food.count)
//        return Constants().food.count
        print("### count is: ", viewModel.getRecipeCount())
        return viewModel.getRecipeCount() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.RECIPE_CELL, for: indexPath) as? RecipeTableViewCell else {
           return UITableViewCell()
        }
//        let food: Food
//        if isSearching() {
//            food = filteredData[indexPath.row]
//        } else {
//            food = Constants().food[indexPath.row]
//        }
        
        /// Find the page with the receipt for the cell
        let pageToGet = indexPath.row / Constants.PAGE_SIZE
            
        /// To get the receipt number within a page of recipes, just need
        /// the modulus of row to page size
        let recipeToGet = indexPath.row % Constants.PAGE_SIZE
        guard let recipe = DataManager.instance.allRecipes[pageToGet].recipes?[recipeToGet] else {
            return UITableViewCell()
        }
        print("#######  CELL: pageToGet, RecipeToGet, recipe", pageToGet, recipeToGet, recipe)
        cell.setupView(recipe: recipe)
        return cell
    }
    
}

// MARK: - Navigation
extension RecipeTableVC {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.TO_RECIPE_DETAIL {
            if let indexPath = tableView.indexPathForSelectedRow {
                let food: Food
                if isSearching() {
                    food = filteredData[indexPath.row]
                } else {
                    food = Constants().food[indexPath.row]
                }
                guard let destination = segue.destination as? RecipeDetailVC else { return }
                print("food to segque: ", food)
                destination.detailFood = food
                // destination.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}


// MARK: - Search
extension RecipeTableVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    /// Returns true if focus in searchbar
    func isSearching() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

    /// Returns true if text is empty or nil
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        print("searchText:", searchText)
        filteredData = Constants().food.filter( {( food: Food) -> Bool in
            return food.name.lowercased().contains(searchText.lowercased())
        })
        print("filteredData", filteredData)
        tableView.reloadData()
    }
}
