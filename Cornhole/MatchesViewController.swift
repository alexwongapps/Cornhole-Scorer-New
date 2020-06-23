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

protocol MatchSettingsHandler {
    func matchSettingsDismissed()
}

class MatchesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MatchSettingsHandler {

    var matches: [Match] = []
    var currentMatch: Match?
    var league: League?
    var editMode = false

    @IBOutlet weak var matchListLabel: UILabel!
    @IBOutlet weak var matchesTableView: UITableView!
    @IBOutlet weak var matchInfoTableView: UITableView!
    @IBOutlet weak var addMatchesToLeagueButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var shareMatchesButton: UIButton!
    @IBOutlet weak var deleteMatchesButton: UIButton!
    @IBOutlet weak var matchView: UIView!
    @IBOutlet weak var matchInfoLabel: UILabel!
    @IBOutlet weak var roundsLabel: UILabel!
    @IBOutlet weak var addToLeagueButton: UIButton!
    @IBOutlet weak var editPlayersButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var refreshButton: UIButton!
    
    // backgrounds
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var matchBackgroundImageView: UIImageView!
    
    // todo: reorder matches?
    
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
        if bigDevice() {
            matchListLabel.font = UIFont(name: systemFont, size: 60)
            roundsLabel.font = UIFont(name: systemFont, size: 30)
            addMatchesToLeagueButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            editButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            deleteMatchesButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            addToLeagueButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            editPlayersButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            shareButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            backButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            refreshButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
        } else {
            matchListLabel.font = UIFont(name: systemFont, size: 30)
            roundsLabel.font = UIFont(name: systemFont, size: 20)
            addMatchesToLeagueButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            editButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            deleteMatchesButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            addToLeagueButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            editPlayersButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            shareButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            backButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            refreshButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
        }
        
        matchListLabel.adjustsFontSizeToFitWidth = true
        matchListLabel.baselineAdjustment = .alignCenters
        matchInfoLabel.adjustsFontSizeToFitWidth = true
        matchInfoLabel.baselineAdjustment = .alignCenters
        backButton.titleLabel?.textAlignment = .right
        addMatchesToLeagueButton.isHidden = true
        deleteMatchesButton.isHidden = true
        
        matchesTableView.accessibilityIdentifier = "ListTable"
        matchInfoTableView.accessibilityIdentifier = "InfoTable"
        activityIndicator.accessibilityIdentifier = "ListActivity"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isLeagueActive() { // no league
            matchListLabel.text = "Match List"
            matches = getMatchesFromCoreData()
            shareButton.isHidden = false
            refreshButton.isHidden = true
            editButton.isHidden = false
            editPlayersButton.isHidden = false
            addToLeagueButton.isHidden = false
        } else { // league
            addToLeagueButton.isHidden = false
            shareButton.isHidden = true
            refreshButton.isHidden = false
            if let league = UserDefaults.getActiveLeague() {
                self.league = league
                self.matchListLabel.text = league.name
                self.matches = league.matches
                self.matchesTableView.reloadData()
                let editor = league.isEditor(user: Auth.auth().currentUser)
                self.editButton.isHidden = !editor
                self.editPlayersButton.isHidden = !editor
            }
        }
        
        if matches.count == 0 {
            matchView.isHidden = true
        }
        
        matchesTableView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        UserDefaults.standard.set(UIDevice.current.orientation.isLandscape, forKey: "isLandscape")
    }
    
    @IBAction func refresh(_ sender: Any) {
        activityIndicator.startAnimating()
        refreshButton.isHidden = true
        CornholeFirestore.pullLeagues(ids: [league!.firebaseID]) { (league, error) in
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
            let fontSize: CGFloat = bigDevice() ? 25 : 17
            
            let cell = matchesTableView.dequeueReusableCell(withIdentifier: "matchCell", for: indexPath) as! MatchesViewControllerMatchTableViewCell
            cell.backgroundColor = .clear
            // let formatter = DateFormatter()
            // formatter.dateStyle = .short
            // let dateString = NSMutableAttributedString(string: formatter.string(from: match.startDate) + " ", attributes: [NSAttributedString.Key.font: UIFont(name: systemFont, size: fontSize)!])
            // dateString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: dateString.length))
            // dateString.append(colorDescription(str: match.description, size: fontSize, redColor: match.redColor, blueColor: match.blueColor))
            let dateString = colorDescription(str: match.description, size: fontSize, redColor: match.redColor, blueColor: match.blueColor)
            cell.matchLabel.attributedText = dateString
            cell.matchLabel.adjustsFontSizeToFitWidth = true
            cell.matchLabel.baselineAdjustment = .alignCenters
            cell.selectionStyle = .none
            cell.arrowLabel.font = UIFont(name: systemFont, size: 25)
            cell.arrowLabel.isHidden = editMode
            
            if editMode {
                let selectedIndexPaths = tableView.indexPathsForSelectedRows
                let rowIsSelected = selectedIndexPaths != nil && selectedIndexPaths!.contains(indexPath)
                cell.accessoryType = rowIsSelected ? .checkmark : .none
            }
            return cell
        } else if let match = currentMatch { // in match view
            
            let cell = matchInfoTableView.dequeueReusableCell(withIdentifier: "matchInfoCell", for: indexPath) as! MatchesViewControllerMatchInfoTableViewCell
            cell.backgroundColor = .clear
            cell.matchLabel.attributedText = colorDescription(str: match.rounds[indexPath.row].description, size: bigDevice() ? 25 : 17, redColor: match.redColor, blueColor: match.blueColor)
            cell.matchLabel.adjustsFontSizeToFitWidth = true
            cell.matchLabel.baselineAdjustment = .alignCenters
            let scoreText = colorDescription(str: "Score: \(match.getScoreAfterRound(round: indexPath.row + 1))", size: bigDevice() ? 25 : 17, redColor: match.redColor, blueColor: match.blueColor)
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
            if !editMode {
                currentMatch = matches[indexPath.row] // used for info
                print(currentMatch!.redPlayers)
                print(currentMatch?.id ?? "No id")
                
                matchView.isHidden = false
                matchInfoLabel.attributedText = colorDescription(str: (currentMatch?.description)!, size: bigDevice() ? 60 : 30, redColor: (currentMatch?.redColor)!, blueColor: (currentMatch?.blueColor)!)
                self.matchInfoTableView.reloadData()
            } else {
                let cell = tableView.cellForRow(at: indexPath)!
                cell.accessoryType = .checkmark
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.tag == 0 {
            let cell = tableView.cellForRow(at: indexPath)!
            cell.accessoryType = .none
        }
    }
    
    // delete match
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if tableView.tag == 0 { // in main view
            if editingStyle == .delete {
                if !isLeagueActive() {
                    deleteMatches(at: [indexPath])
                } else {
                    if !(league?.isEditor(user: Auth.auth().currentUser))! {
                        self.present(createBasicAlert(title: "Unable to delete match", message: "Log in to an editor account for this league"), animated: true, completion: nil)
                    } else {
                        deleteMatches(at: [indexPath])
                    }
                }
            }
        }
    }
    
    func deleteMatches(at: [IndexPath]) {
        // put indices in reverse order
        let indices = at.sorted { $0.row > $1.row }
        
        if !isLeagueActive() {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Matches")
            request.returnsObjectsAsFaults = false
            
            // delete
            do {
                let results = try context.fetch(request)

                // collect match ids
                var matchIDs = [Int]()
                for path in indices {
                    matchIDs.append(matches[path.row].id)
                }
                
                for result in results as! [NSManagedObject] {
                    if matchIDs.contains(result.value(forKey: "id") as! Int) {
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
                for i in 0..<indices.count {
                    matches.remove(at: indices[i].row)
                    matchesTableView.deleteRows(at: [indices[i]], with: .fade)
                }
            } catch {
                let saveError = error as NSError
                print(saveError)
            }
        } else {
            if let league = UserDefaults.getActiveLeague() {
                var rows = [Int]()
                for ind in indices {
                    rows.append(ind.row)
                }
                rows = rows.sorted { $0 > $1 }
                CornholeFirestore.deleteMatchesFromLeague(leagueID: league.firebaseID, indices: rows)
                for i in 0..<indices.count {
                    matches.remove(at: indices[i].row)
                    matchesTableView.deleteRows(at: [indices[i]], with: .fade)
                }
            }
        }
    }
    
    @IBAction func editMatches(_ sender: Any) {
        // deselect all rows
        for i in 0..<matchesTableView.numberOfRows(inSection: 0) {
            matchesTableView.deselectRow(at: IndexPath(row: i, section: 0), animated: false)
            if let cell = matchesTableView.cellForRow(at: IndexPath(row: i, section: 0)) {
                cell.accessoryType = .none
            }
        }
        editMode = !editMode
        addMatchesToLeagueButton.isHidden = !editMode
        shareMatchesButton.isHidden = true // todo: this
        deleteMatchesButton.isHidden = !editMode
        if editMode {
            matchesTableView.allowsMultipleSelection = true
            editButton.setTitle("Done", for: .normal)
            editButton.setTitle("Done", for: .selected)
        } else {
            matchesTableView.allowsMultipleSelection = false
            editButton.setTitle("Edit", for: .normal)
            editButton.setTitle("Edit", for: .selected)
        }
        matchesTableView.reloadData()
    }
    
    @IBAction func shareMatches(_ sender: Any) {
        
    }
    
    @IBAction func deleteMatches(_ sender: Any) {
        let selectedRows = matchesTableView.indexPathsForSelectedRows
        if let rs = selectedRows {
            deleteMatches(at: rs)
        }
        editMatches(editButton!)
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
            popover.sourceView = shareButton
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
    
    // edit match players
    
    @IBAction func editPlayers(_ sender: Any) {
        performSegue(withIdentifier: "matchSettingsSegue", sender: nil)
    }
    
    func matchSettingsDismissed() {
        matchView.isHidden = true
        viewWillAppear(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "matchSettingsSegue":
            let controller = segue.destination as! MatchSettingsViewController
            controller.match = currentMatch
            if isLeagueActive() {
                if let league = UserDefaults.getActiveLeague() {
                    controller.league = league
                }
            }
            controller.delegate = self
        default:
            break
        }
    }
    
    // add to league
    @IBAction func addMatchToLeague(_ sender: Any) {
        if let user = Auth.auth().currentUser {
            activityIndicator.startAnimating()
            CornholeFirestore.pullAndCacheLeagues(force: false) { (error, unables) in
                self.activityIndicator.stopAnimating()
                if error != nil {
                    self.present(createBasicAlert(title: "Error", message: "Unable to access leagues"), animated: true, completion: nil)
                }
                if let ids = unables {
                    if ids.count > 0 {
                        self.present(createBasicAlert(title: "Error", message: deletedLeagueMessage(ids: ids)), animated: true, completion: nil)
                        for id in ids {
                            UserDefaults.removeLeagueID(id: id)
                        }
                        CornholeFirestore.setLeagues(user: user)
                    }
                }
                if cachedLeagues.count == 0 {
                    self.present(createBasicAlert(title: "No Leagues Added", message: "Create or add a league from the Edit Leagues menu"), animated: true)
                } else {
                    let alert = UIAlertController(title: "Select League", message: "Don't see a league? You may not be an editor for it", preferredStyle: .alert)
                    for league in cachedLeagues {
                        if league.firebaseID != UserDefaults.getActiveLeagueID() && league.isEditor(user: user) {
                            alert.addAction(UIAlertAction(title: league.name, style: .default, handler: { (action) in
                                CornholeFirestore.addMatchToLeague(leagueID: league.firebaseID, match: self.currentMatch!)
                            }))
                        }
                    }
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                    
                    // ipad support
                    if let popover = alert.popoverPresentationController {
                        popover.sourceView = self.addToLeagueButton
                    }
                }
            }
        } else {
            self.present(createBasicAlert(title: "Not Logged In", message: "Log in from the Leagues tab to add this match to a league"), animated: true)
        }
    }
    
    @IBAction func addMatchesToLeague(_ sender: Any) {
        let selectedRows = matchesTableView.indexPathsForSelectedRows
        if let rs = selectedRows {
            addLeagueMatches(at: rs)
        } else {
            self.present(createBasicAlert(title: "No Matches Selected", message: "Select the matches to be added"), animated: true)
        }
        editMatches(editButton!)
    }
    
    func addLeagueMatches(at: [IndexPath]) {
        if let user = Auth.auth().currentUser {
            activityIndicator.startAnimating()
            CornholeFirestore.pullAndCacheLeagues(force: false) { (error, unables) in
                self.activityIndicator.stopAnimating()
                if error != nil {
                    self.present(createBasicAlert(title: "Error", message: "Unable to access leagues"), animated: true, completion: nil)
                }
                if let ids = unables {
                    if ids.count > 0 {
                        self.present(createBasicAlert(title: "Error", message: deletedLeagueMessage(ids: ids)), animated: true, completion: nil)
                        for id in ids {
                            UserDefaults.removeLeagueID(id: id)
                        }
                        CornholeFirestore.setLeagues(user: user)
                    }
                }
                if cachedLeagues.count == 0 {
                    self.present(createBasicAlert(title: "No Leagues Added", message: "Create or add a league from the Edit Leagues menu"), animated: true)
                } else {
                    let alert = UIAlertController(title: "Select League", message: "Don't see a league? You may not be an editor for it", preferredStyle: .alert)
                    for league in cachedLeagues {
                        if league.firebaseID != UserDefaults.getActiveLeagueID() && league.isEditor(user: user) {
                            alert.addAction(UIAlertAction(title: league.name, style: .default, handler: { (action) in

                                let s = at.sorted { (a, b) -> Bool in
                                    a.row < b.row
                                }
                                
                                // collect matches
                                var toAdd = [Match]()
                                for indexPath in s {
                                    toAdd.append(self.matches[indexPath.row])
                                }
                                
                                CornholeFirestore.addMatchesToLeague(leagueID: league.firebaseID, matches: toAdd)
                            }))
                        }
                    }
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                    
                    // ipad support
                    if let popover = alert.popoverPresentationController {
                        popover.sourceView = self.editButton
                    }
                }
            }
        } else {
            self.present(createBasicAlert(title: "Not Logged In", message: "Log in from the Leagues tab to add this match to a league"), animated: true)
        }
    }
}

