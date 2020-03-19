//
//  StandingsViewControllerRowTableViewCell.swift
//  Cornhole Scorer
//
//  Created by Alex Wong on 3/18/20.
//  Copyright © 2020 Kids Can Code. All rights reserved.
//

import UIKit

class StandingsViewControllerRowTableViewCell: UITableViewCell {

    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var recordLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
