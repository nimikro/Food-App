//
//  CellCategory.swift
//  FoodApp
//
//  Created by Panagiota on 1/12/21.
//

import UIKit
// cell for showing categories
class CategoryCell: UITableViewCell {

    @IBOutlet weak var categoryCell: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(categoryCell)
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: true)
    }
}
