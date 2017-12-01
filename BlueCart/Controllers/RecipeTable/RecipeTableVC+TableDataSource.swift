//
//  RecipeTableVC+TableDataSource.swift
//  BlueCart
//
//  Created by David Rothschild on 12/1/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import UIKit

// MARK: - Prefetch data for tablevView
extension RecipeTableVC {
    
    /// Here we prefetch the images for the tableview using Kingfisher.
    /// And, prefetch more data if the user is getting to the end of the tableview.
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        /// If offline, don't do prefetching of data
        if reachability.connection == .none || viewModel.isSearching == true {
            print("isSearching")
            return
        }
        let currentPage = viewModel.currentPageNumber.value
        
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
            viewModel.loadRecipesForExistingSearchTerm()
        }
    }
}

// MARK: - Table view data source
extension RecipeTableVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// Load different data sets depending on status of search bar and if text has been entered.
    /// The + 1 is for offline as the Top Rated is inserted as the first search term.
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
    
    /// Function to delete saved search terms.
    /// Put up "Not Available" notice in table view when recipes are showing.
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if searchController.isActive {
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
                self?.searchTerms.remove(at: indexPath.row - 1)
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                guard let searchTerm = self?.viewModel.searchTerms.value[indexPath.row - 1] else { return }
                SearchTerms().deleteSearchTerm(searchTerm: searchTerm)
                self?.presentModalStatusView(headLine: "Deleted", subHead: "search term")
            }
            return [deleteAction]
        } else {
            let noAction = UITableViewRowAction(style: .normal, title: "Not Available") { (_, indexPath) in
                print("Delete not available for recipes")
            }
            return [noAction]
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
        
        recipe = viewModel.getRecipe(pageToGet: pageToGet, recipeToGet: recipeToGet, index: index)
        return recipe
    }
}

