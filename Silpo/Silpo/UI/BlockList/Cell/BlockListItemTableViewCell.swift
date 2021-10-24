//
//  BlockListItemTableViewCell.swift
//  Silpo
//
//  Created by Prefect on 23.10.2021.
//

import UIKit

class BlockListItemTableViewCell: UITableViewCell {
        
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with name: String) {
        titleLabel.text = name
    }
    
}
