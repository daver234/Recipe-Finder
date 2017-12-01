//
//  RecipeTableVC+UISearchBar.swift
//  BlueCart
//
//  Created by David Rothschild on 11/30/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import UIKit
import ModalStatus

/// All Search Controller searchBar related functions
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
    }
    
    /// Save search text to CoreData
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchText = searchController.searchBar.text else { return }
        viewModel.saveSearchTerm(term: searchText)
        presentModalStatusView(headLine: "Saved", subHead: "search term")
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
    
    /// As the user types adjust the data source to match what reamins
    /// in the searchTerms array
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredSearchTerms = searchTerms.filter( { (text: String) -> Bool in
            return text.contains(searchText.lowercased())
        })
    }
    
    /// Presents Apple style blur modal status view
    func presentModalStatusView(headLine: String, subHead: String) {
        let modalView = ModalStatusView(frame: self.view.bounds)
        let saveImage = UIImage(named: Constants.CHECKMARK) ?? UIImage()
        modalView.set(image: saveImage)
        modalView.set(headline: headLine)
        modalView.set(subheading: subHead)
        view.addSubview(modalView)
    }
}
