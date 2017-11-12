//
//  SearchBarVC.swift
//  BlueCart
//
//  Created by David Rothschild on 11/11/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import UIKit

class SearchBarVC: UIViewController, UISearchBarDelegate {
    
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        // tableView.dataSource = self
    }

}


extension SearchBarVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.SEARCH_CELL, for: indexPath) as? SearchBarTableViewCell else {
            return UITableViewCell()
        }
        return cell
    }
}


extension SearchBarVC:  UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("coming soon")
    }
}
