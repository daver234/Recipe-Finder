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
    
    // MARK: - Functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setupView(recipe: Recipe) {
        guard let title = recipe.title else { return }
        recipeTitleLabel.text = title
        print("recipe title", recipe.title ?? "")
        /// First get image out of assets as a placeholder while downloading the image from a URL
        let image = UIImage(named: Constants.LOADING_IMAGE)
        guard let urlString = recipe.imageUrl, let url = URL(string: urlString) else { return }
        DispatchQueue.main.async {
            self.recipeImage.kf.setImage(with: url, placeholder: image)
        }
    }
}
