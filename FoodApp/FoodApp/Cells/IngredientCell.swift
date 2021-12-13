//
//  IngredientCell.swift
//  FoodApp
//
//  Created by Nikolaos Mikrogeorgiou on 30/11/21.
//

import UIKit

// cell for ingredients table
class IngredientCell: UITableViewCell {
    
    @IBOutlet weak var ingredientLabel: UILabel!
    @IBOutlet weak var ingredientIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: true)
    }
}
