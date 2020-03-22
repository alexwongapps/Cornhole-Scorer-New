//
//  MatchesViewControllerMatchTableViewCell.swift
//  Cornhole
//
//  Created by Alex Wong on 7/6/18.
//  Copyright © 2018 Kids Can Code. All rights reserved.
//

import UIKit

class MatchesViewControllerMatchTableViewCell: UITableViewCell {

    @IBOutlet weak var arrowLabel: UILabel!
    @IBOutlet weak var matchLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
