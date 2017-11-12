//
//  RecipeTableViewCell.swift
//  BlueCart
//
//  Created by David Rothschild on 11/6/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import UIKit
import Kingfisher

class RecipeTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeTitleLabel: UILabel!
    @IBOutlet weak var recipeImageHeight: NSLayoutConstraint!
    
    // MARK: - Functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setupView(recipe: Recipe) {
        recipeImage.isHidden = false
        recipeImageHeight.constant = 150

        guard let title = recipe.title else { return }
        recipeTitleLabel.text = title
        
        /// First get image out of assets as a placeholder while downloading the image from a URL
        let image = UIImage(named: Constants.LOADING_IMAGE)
        guard let urlString = recipe.imageUrl, let url = URL(string: urlString) else { return }
        DispatchQueue.main.async {
            self.recipeImage.kf.setImage(with: url, placeholder: image)
        }
    }
    
    /// Function for when search occurs
    /// Hides image and changes cell height for just saved search text string
    func setupViewIfCoreData(searchTerm: String) {
        recipeImage.isHidden = true
        recipeImageHeight.constant = 35
        recipeTitleLabel.text = searchTerm
    }
}
