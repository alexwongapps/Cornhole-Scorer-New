//
//  SecondViewController.swift
//  Cornhole
//
//  Created by Alex Wong on 7/2/18.
//  Copyright © 2018 Kids Can Code. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth

class MatchesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var matches: [Match] = []
    var currentMatch: Match?
    var league: League?

    @IBOutlet weak var matchListLabel: UILabel!
    @IBOutlet weak var matchesTableView: UITableView!
    @IBOutlet weak var matchInfoTableView: UITableView!
    @IBOutlet weak var matchView: UIView!
    @IBOutlet weak var matchInfoLabel: UILabel!
    @IBOutlet weak var roundsLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var refreshButton: UIButton!
    
    // backgrounds
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var matchBackgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        
        backgroundImageView.image = backgroundImage
        matchBackgroundImageView.image = backgroundImage
        
        matchListLabel.text = ""
        
        matchesTableView.backgroundColor = .clear
        matchInfoTableView.backgroundColor = .clear
        
        // fonts
        if hasTraits(view: self.view, width: UIUserInterfaceSizeClass.regular, height: UIUserInterfaceSizeClass.regular) {
            
            matchListLabel.font = UIFont(name: systemFont, size: 60)
            roundsLabel.font = UIFont(name: systemFont, size: 30)
            shareButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            backButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            refreshButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            
        } else {
            
            matchListLabel.font = UIFont(name: systemFont, size: 25)
            roundsLabel.font = UIFont(name: systemFont, size: 20)
            shareButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            backButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            refreshButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
        }
        
        backButton.titleLabel?.textAlignment = .right
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isLeagueActive() { // no league
            matchListLabel.text = "Match List"
            matches = getMatchesFromCoreData()
            shareButton.isHidden = false
            refreshButton.isHidden = true
        } else { // league
            shareButton.isHidden = true
            refreshButton.isHidden = false
            if let league = UserDefaults.getActiveLeague() {
                self.league = league
                self.matchListLabel.text = league.name
                self.matches = league.matches
                self.matchesTableView.reloadData()
            }
        }
        
        if matches.count == 0 {
            matchView.isHidden = true
        }
        
        self.matchesTableView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        UserDefaults.standard.set(UIDevice.current.orientation.isLandscape, forKey: "isLandscape")
    }
    
    @IBAction func refresh(_ sender: Any) {
        activityIndicator.startAnimating()
        refreshButton.isHidden = true
        CornholeFirestore.pullLeague(id: league!.firebaseID) { (league, error) in
            self.activityIndicator.stopAnimating()
            self.refreshButton.isHidden = false
            if error != nil {
                self.present(createBasicAlert(title: "Error", message: "Unable to pull current league"), animated: true, completion: nil)
            } else {
                self.viewWillAppear(true)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 0 { // in main view
            return matches.count
        } else if let match = currentMatch { // in match view
            return match.rounds.count
        } else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 0 { // in main view
            let match = matches[indexPath.row]
            
            let cell = matchesTableView.dequeueReusableCell(withIdentifier: "matchCell", for: indexPath) as! MatchesViewControllerMatchTableViewCell
            cell.backgroundColor = .clear
            cell.textLabel?.attributedText = colorDescription(str: match.description, size: hasTraits(view: self.view, width: UIUserInterfaceSizeClass.regular, height: UIUserInterfaceSizeClass.regular) ? 25 : 17, redColor: match.redColor, blueColor: match.blueColor)
            cell.selectionStyle = .none
            cell.arrowLabel.font = UIFont(name: systemFont, size: 25)
            return cell
        } else if let match = currentMatch { // in match view
            
            let cell = matchInfoTableView.dequeueReusableCell(withIdentifier: "matchInfoCell", for: indexPath) as! MatchesViewControllerMatchInfoTableViewCell
            cell.backgroundColor = .clear
            cell.textLabel?.attributedText = colorDescription(str: match.rounds[indexPath.row].description, size: hasTraits(view: matchView, width: UIUserInterfaceSizeClass.regular, height: UIUserInterfaceSizeClass.regular) ? 25 : 17, redColor: match.redColor, blueColor: match.blueColor)
            
            let scoreText = colorDescription(str: "Score: \(match.getScoreAfterRound(round: indexPath.row + 1))", size: hasTraits(view: matchView, width: UIUserInterfaceSizeClass.regular, height: UIUserInterfaceSizeClass.regular) ? 25 : 17, redColor: match.redColor, blueColor: match.blueColor)
            scoreText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: "Score: ".count))
            cell.matchScoreLabel.attributedText = scoreText
            cell.selectionStyle = .none
            return cell
        } else {
            return UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "matchInfoCell")
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 0 { // on main view
        
            currentMatch = matches[indexPath.row] // used for info
            print(currentMatch!.redPlayers)
            print(currentMatch?.id ?? "No id")
            
            matchView.isHidden = false
            matchInfoLabel.attributedText = colorDescription(str: (currentMatch?.description)!, size: hasTraits(view: self.view, width: UIUserInterfaceSizeClass.regular, height: UIUserInterfaceSizeClass.regular) ? 25 : 17, redColor: (currentMatch?.redColor)!, blueColor: (currentMatch?.blueColor)!)
            self.matchInfoTableView.reloadData()
        }
    }
    
    // delete match
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if tableView.tag == 0 { // in main view
            if editingStyle == .delete {
                if !isLeagueActive() {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Matches")
                    request.returnsObjectsAsFaults = false
                    
                    // delete
                    do {
                        let results = try context.fetch(request)
                        
                        for result in results as! [NSManagedObject] {
                            let match = matches[indexPath.row]
                            
                            if result.value(forKey: "id") as! Int == match.id {
                                context.delete(result)
                            }
                        }
                    } catch {
                        let saveError = error as NSError
                        print(saveError)
                    }
                    
                    // save
                    do {
                        try context.save()
                        matches.remove(at: indexPath.row)
                        matchesTableView.deleteRows(at: [indexPath], with: .fade)
                    } catch {
                        let saveError = error as NSError
                        print(saveError)
                    }
                } else {
                    if !(league?.isEditor(user: Auth.auth().currentUser))! {
                        self.present(createBasicAlert(title: "Unable to delete match", message: "Log in to an editor account for this league"), animated: true, completion: nil)
                    } else {
                        print(matches[indexPath.row].firebaseID)
                        CornholeFirestore.deleteMatchFromLeague(leagueID: UserDefaults.getActiveLeagueID(), matchID: matches[indexPath.row].firebaseID) { (err) in
                            if let err = err {
                                print("error deleting match: \(err)")
                            } else {
                                self.matches.remove(at: indexPath.row)
                                self.matchesTableView.deleteRows(at: [indexPath], with: .fade)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        matchView.isHidden = true
    }
    
    @IBAction func shareMatch(_ sender: Any) {
        if firstShareWithDataModelTwo() {
            let alert = UIAlertController(title: "Sharing a match?", message: "Make sure the receiving device has at least version 2.2 (first version with different game types)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) in
                self.exportMatch()
            }))
            present(alert, animated: true, completion: nil)
        } else {
            exportMatch()
        }
    }
    
    func exportMatch() {
        guard let match = currentMatch,
            let url = match.exportToFileURL() else {
                return
        }
        
        let vc = UIActivityViewController(activityItems: ["Check out this match I played using The Cornhole Scorer!", url], applicationActivities: nil)
        vc.excludedActivityTypes = [
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.postToFacebook,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToTwitter,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.saveToCameraRoll
        ]
        
        present(vc, animated: true, completion: nil)
        
        // ipad support
        if let popover = vc.popoverPresentationController {
            popover.sourceView = self.view
        }
    }
    
    func firstShareWithDataModelTwo() -> Bool {
        let alreadyShared = UserDefaults.standard.bool(forKey: "alreadySharedWithDataModelTwo")
        if alreadyShared {
            // UserDefaults.standard.set(false, forKey: "alreadySharedWithDataModelTwo")
            return false
        } else {
            UserDefaults.standard.set(true, forKey: "alreadySharedWithDataModelTwo")
            return true
        }
    }
}

