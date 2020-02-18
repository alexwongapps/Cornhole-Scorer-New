//
//  EditLeaguesViewController.swift
//  Cornhole Scorer
//
//  Created by Alex Wong on 10/12/19.
//  Copyright © 2019 Kids Can Code. All rights reserved.
//

import UIKit
import FirebaseAuth

class EditLeaguesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var leagues: [League] = []
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var leaguesTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backgroundImageView.image = backgroundImage
        
        // devices
        
        if hasTraits(view: self.view, width: UIUserInterfaceSizeClass.regular, height: UIUserInterfaceSizeClass.regular) {
            
            backButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            createButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            joinButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            helpButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
        } else if smallDevice() {
            backButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            createButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            joinButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            helpButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
        } else {
            backButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            createButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            joinButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            helpButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("cached leagues: \(cachedLeagues.count)")
        print("active league: \(UserDefaults.getActiveLeagueID())")
        
        leagues.removeAll()
        
        if !isLeagueActive() { // only get pull/cache if not already done by scoreboard
            activityIndicator.startAnimating()
            CornholeFirestore.pullAndCacheLeagues { (message) in
                self.activityIndicator.stopAnimating()
                if let m = message {
                    self.present(createBasicAlert(title: "Error", message: m), animated: true, completion: nil)
                }
                for league in cachedLeagues {
                    self.leagues.append(league)
                }
                self.leaguesTableView.reloadData()
            }
        } else {
            for league in cachedLeagues {
                self.leagues.append(league)
            }
            self.leaguesTableView.reloadData()
        }
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createLeague(_ sender: Any) {
        if let user = Auth.auth().currentUser {
            let alert = UIAlertController(title: "Create League", message: "Enter the league name", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addTextField { (textField) in
                textField.placeholder = "Name"
            }
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
                if textField?.text != "" {
                    let newLeague = League(name: textField!.text!, owner: user)
                    self.activityIndicator.startAnimating()
                    newLeague.getNewID(completion: { (error) in
                        self.activityIndicator.stopAnimating()
                        if error == nil {
                            self.leagues.append(newLeague)
                            self.leaguesTableView.reloadData()
                            CornholeFirestore.createLeague(league: newLeague)
                            var oldIDs = UserDefaults.getLeagueIDs()
                            oldIDs.append(newLeague.id)
                            UserDefaults.setLeagueIDs(ids: oldIDs)
                            UserDefaults.setActiveLeagueID(id: newLeague.id)
                            self.openDetail(indexPath: IndexPath(row: self.leagues.count - 1, section: 0))
                        } else {
                            self.present(createBasicAlert(title: "Error", message: "Unable to create league. Check your internet connection."), animated: true, completion: nil)
                        }
                    })
                }
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.present(createBasicAlert(title: "Not logged in", message: "Must be logged in to create a league"), animated: true, completion: nil)
       }
    }
    
    @IBAction func joinLeague(_ sender: Any) {
        let alert = UIAlertController(title: "Join League", message: "Enter the league ID", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "ID"
        }
        alert.addAction(UIAlertAction(title: "Join", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if textField?.text != "" {
                if Int(textField!.text!) != nil {
                    self.activityIndicator.startAnimating()
                    CornholeFirestore.pullLeague(id: Int(textField!.text!)!) { (league, err) in
                        self.activityIndicator.stopAnimating()
                        if let err = err {
                            print("error pulling league: \(err)")
                            self.present(createBasicAlert(title: "Error", message: "Unable to join league. Check your internet connection"), animated: true, completion: nil)
                        } else if league!.name == "" {
                            self.present(createBasicAlert(title: "League not found", message: "A league with this ID was not found"), animated: true, completion: nil)
                        } else {
                            self.leagues.append(league!)
                            self.leaguesTableView.reloadData()
                            var oldIDs = UserDefaults.getLeagueIDs()
                            oldIDs.append(league!.id)
                            UserDefaults.setLeagueIDs(ids: oldIDs)
                            UserDefaults.setActiveLeagueID(id: league!.id)
                        }
                    }
                } else {
                    self.present(createBasicAlert(title: "Not a valid league ID", message: "The league ID is a number that can be found on the league detail page."), animated: true, completion: nil)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leagues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leagueCell") as! EditLeaguesViewControllerLeagueTableViewCell
        cell.league = leagues[indexPath.row]
        cell.nameLabel.text = cell.league.name
        cell.makeActiveButton.setTitle(UserDefaults.getActiveLeagueID() == cell.league.id ? "Make Not Active" : "Make Active", for: .normal)
        cell.backgroundColor = .clear
        
        // fonts
        if hasTraits(view: self.view, width: UIUserInterfaceSizeClass.regular, height: UIUserInterfaceSizeClass.regular) {
            
            cell.nameLabel.font = UIFont(name: systemFont, size: 30)
            cell.makeActiveButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
        } else if smallDevice() {
            cell.nameLabel.font = UIFont(name: systemFont, size: 17)
            cell.makeActiveButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
        } else {
            cell.nameLabel.font = UIFont(name: systemFont, size: 17)
            cell.makeActiveButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if leagues[indexPath.row].id == UserDefaults.getActiveLeagueID() {
                UserDefaults.setActiveLeagueID(id: CornholeFirestore.TEST_LEAGUE_ID)
            }
            leagues.remove(at: indexPath.row)
            leaguesTableView.deleteRows(at: [indexPath], with: .fade)
            leaguesTableView.reloadData()
            var oldIDs = UserDefaults.getLeagueIDs()
            oldIDs.remove(at: indexPath.row)
            UserDefaults.setLeagueIDs(ids: oldIDs)
        }
    }
    
    @IBAction func help(_ sender: Any) {
        self.present(createBasicAlert(title: "Help", message: "\nCreate: Create a new league\n\nJoin: Add a league to view — whether or not you can edit it is determined by th league owner\n\nMake Active/Not Active: Sets which league you are currently viewing/editing. To view local data, make sure all leagues are not active"), animated: true, completion: nil)
    }
    
    @IBAction func makeActive(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: leaguesTableView)
        let indexPath = leaguesTableView.indexPathForRow(at: buttonPosition)
        let cell = leaguesTableView.cellForRow(at: indexPath!) as! EditLeaguesViewControllerLeagueTableViewCell
        
        if UserDefaults.getActiveLeagueID() == cell.league.id { // deactivate
            UserDefaults.setActiveLeagueID(id: CornholeFirestore.TEST_LEAGUE_ID)
        } else { // activate
            UserDefaults.setActiveLeagueID(id: cell.league.id)
        }
        leaguesTableView.reloadData()
    }
    
    var selectedLeague: League?
    
    func openDetail(indexPath: IndexPath) {
        selectedLeague = leagues[indexPath.row]
        performSegue(withIdentifier: "leagueDetailSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openDetail(indexPath: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "leagueDetailSegue":
            let controller = segue.destination as! LeagueDetailViewController
            controller.title = selectedLeague!.name
            controller.league = selectedLeague
        default:
            break
        }
    }
}
