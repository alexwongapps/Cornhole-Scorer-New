//
//  EditLeaguesViewControllerLeagueTableViewCell.swift
//  Cornhole Scorer
//
//  Created by Alex Wong on 12/3/19.
//  Copyright © 2019 Kids Can Code. All rights reserved.
//

import UIKit

class EditLeaguesViewControllerLeagueTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var makeActiveButton: UIButton!
    var league: League = League()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
