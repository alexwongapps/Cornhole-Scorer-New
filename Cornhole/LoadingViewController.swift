//
//  LoadingViewController.swift
//  Cornhole Scorer
//
//  Created by Alex Wong on 3/22/20.
//  Copyright © 2020 Kids Can Code. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var deactivateButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var okButton: UIButton!
    
    var league: League?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if isLeagueActive() {
            activityIndicator.startAnimating()
            CornholeFirestore.pullLeagues(ids: [UserDefaults.getActiveLeagueID()]) { (leagues, error) in
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                if error != nil {
                    self.failed(message: "Unable to pull league \(UserDefaults.getActiveLeagueID())")
                } else if leagues!.count == 0 {
                    self.failed(message: "Unable to pull league \(UserDefaults.getActiveLeagueID()), it may have been deleted")
                    UserDefaults.setActiveLeagueID(id: CornholeFirestore.TEST_LEAGUE_ID)
                } else {
                    if let league = leagues?[0] {
                        self.league = league
                        self.performSegue(withIdentifier: "startSegue", sender: nil)
                    }
                }
            }
        }
    }
    
    func failed(message: String) {
        loadingLabel.text = message
        UserDefaults.setActiveLeagueID(id: CornholeFirestore.TEST_LEAGUE_ID)
        deactivateButton.isHidden = true
        okButton.isHidden = false
    }
    
    @IBAction func deactivate(_ sender: Any) {
        UserDefaults.setActiveLeagueID(id: CornholeFirestore.TEST_LEAGUE_ID)
        performSegue(withIdentifier: "startSegue", sender: nil)
    }
    
    @IBAction func ok(_ sender: Any) {
        performSegue(withIdentifier: "startSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // start segue
        let controller = segue.destination as! UITabBarController
        let root = controller.selectedViewController as! ScoreboardViewController
        if let l = league {
            root.league = l
        }
    }
}
