//
//  StandingsViewController.swift
//  Cornhole Scorer
//
//  Created by Alex Wong on 3/18/20.
//  Copyright © 2020 Kids Can Code. All rights reserved.
//

import UIKit

class StandingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var standingsLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var standingsTableView: UITableView!
    
    var data: [String : [Double]] = [:] // data is [won, lost, tied, percent, score/round]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        backgroundImageView.image = backgroundImage
        
        // fonts
        if bigDevice() {
            
            standingsLabel.font = UIFont(name: systemFont, size: 60)
            backButton.titleLabel?.font = UIFont(name: systemFont, size: 25)
        } else {
            
            standingsLabel.font = UIFont(name: systemFont, size: 30)
            backButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
        }
    }

    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sortedData = data.sorted(by: { (p0, p1) -> Bool in
            if p0.value[3] > p1.value[3] {
                return true
            } else if p0.value[3] < p1.value[3] {
                return false
            } else if p0.value[4] > p1.value[4] {
                return true
            }
            return false
        })
        let thisData = sortedData[indexPath.row]
        let cell = standingsTableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath) as! StandingsViewControllerRowTableViewCell
        
        let size: CGFloat = bigDevice() ? 30 : 17
        
        cell.rankLabel.font = UIFont(name: systemFont, size: size)
        cell.playerLabel.font = UIFont(name: systemFont, size: size)
        cell.recordLabel.font = UIFont(name: systemFont, size: size)
        
        cell.rankLabel.text = "\(indexPath.row + 1)."
        cell.playerLabel.text = thisData.key
        cell.recordLabel.text = "\(Int(thisData.value[0]))–\(Int(thisData.value[1]))"
        return cell
    }
}
