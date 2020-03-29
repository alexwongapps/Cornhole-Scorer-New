//
//  LeagueDetailViewController.swift
//  Cornhole Scorer
//
//  Created by Alex Wong on 10/12/19.
//  Copyright © 2019 Kids Can Code. All rights reserved.
//

import UIKit
import FirebaseAuth

class LeagueDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var league: League?
    
    @IBOutlet weak var playersTableView: UITableView!
    @IBOutlet weak var editorsTableView: UITableView!
    @IBOutlet weak var qrButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var playersLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var editorsLabel: UILabel!
    @IBOutlet weak var editorsAddButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var deleteLeagueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }

        // Do any additional setup after loading the view.
        backgroundImageView.image = backgroundImage
        idLabel.text = "ID: \(league?.firebaseID ?? League.NEW_ID_FAILED)"
        
        let isOwner = (league?.isOwner(user: Auth.auth().currentUser))!
        let isEditor = (league?.isEditor(user: Auth.auth().currentUser))!
        
        addButton.isHidden = !isEditor
        editorsLabel.isHidden = !isEditor
        editorsAddButton.isHidden = !isOwner
        editorsTableView.isHidden = !isEditor
        deleteLeagueButton.isHidden = !isOwner
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if bigDevice() {
            
            helpButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            qrButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            idLabel.font = UIFont(name: "Courier", size: 30)
            playersLabel.font = UIFont(name: systemFont, size: 30)
            addButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            editorsLabel.font = UIFont(name: systemFont, size: 30)
            editorsAddButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            deleteLeagueButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
        } else if smallDevice() {
            helpButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            qrButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            idLabel.font = UIFont(name: "Courier", size: 12)
            playersLabel.font = UIFont(name: systemFont, size: 17)
            addButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            editorsLabel.font = UIFont(name: systemFont, size: 17)
            editorsAddButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            deleteLeagueButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
        } else {
            helpButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            qrButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            idLabel.font = UIFont(name: "Courier", size: 17)
            playersLabel.font = UIFont(name: systemFont, size: 17)
            addButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            editorsLabel.font = UIFont(name: systemFont, size: 17)
            editorsAddButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            deleteLeagueButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if first30Launch() {
            help(helpButton!)
        }
    }
    
    @IBAction func addPlayer(_ sender: Any) {
        let alert = UIAlertController(title: "Add Player(s)", message: "Enter player names, separated by \(CornholeFirestore.DELIMITER_NAME_PLURAL) (\(CornholeFirestore.PLAYER_NAMES_DELIMITER))", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
            textField.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if textField?.text != "" {
                
                // parse
                let newPlayers = textField!.text!
                let arr = newPlayers.split(separator: CornholeFirestore.PLAYER_NAMES_DELIMITER)
                var players = [String]()
                for p in arr {
                    let q = p.trimmingCharacters(in: .whitespacesAndNewlines)
                    if q.count > 0 {
                        players.append(q)
                    }
                }
                
                var actuals = [String]()
                for newPlayer in players {
                    if (self.league?.players.contains(newPlayer))! {
                        let repeatAlert = UIAlertController(title: "Invalid name", message: "\(newPlayer) already in league", preferredStyle: .alert)
                        repeatAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.self.present(repeatAlert, animated: true, completion: nil)
                    } else {
                        actuals.append(newPlayer)
                    }
                }
                if actuals.count > 0 {
                    CornholeFirestore.addPlayersToLeague(leagueID: self.league?.firebaseID ?? League.NEW_ID_FAILED, playerNames: actuals)
                    self.playersTableView.reloadData()
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addEditor(_ sender: Any) {
        let alert = UIAlertController(title: "Add Editor", message: "Enter the editor's email", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField { (textField) in
            textField.placeholder = "Email"
        }
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if textField?.text != "" {
                let newEditorEmail = textField!.text!
            
                // only editors can delete matches
                
                if (self.league?.editorEmails.contains(newEditorEmail))! {
                    let repeatAlert = UIAlertController(title: "Already an editor", message: "\(newEditorEmail) is already an editor", preferredStyle: .alert)
                    repeatAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.self.present(repeatAlert, animated: true, completion: nil)
                } else {
                    CornholeFirestore.addEditorToLeague(leagueID: self.league?.firebaseID ?? League().firebaseID, editorEmail: newEditorEmail)
                    self.editorsTableView.reloadData()
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.tag == 0 ? (league?.players.count)! : (league?.editorEmails.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "leaguePlayerCell")!
            cell.textLabel!.text = league?.players[indexPath.row]
            cell.backgroundColor = .clear
            
            // fonts
            if bigDevice() {
                cell.textLabel!.font = UIFont(name: systemFont, size: 30)
            } else if smallDevice() {
                cell.textLabel!.font = UIFont(name: systemFont, size: 17)
            } else {
                cell.textLabel!.font = UIFont(name: systemFont, size: 17)
            }
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "leagueEditorCell")!
            cell.textLabel?.text = league?.editorEmails[indexPath.row]
            cell.backgroundColor = .clear
            
            // fonts
            if bigDevice() {
                cell.textLabel!.font = UIFont(name: systemFont, size: 30)
            } else if smallDevice() {
                cell.textLabel!.font = UIFont(name: systemFont, size: 17)
            } else {
                cell.textLabel!.font = UIFont(name: systemFont, size: 17)
            }
            
            return cell
        }
    }
    
    // delete player name
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if tableView.tag == 0 {
        
            if editingStyle == .delete {
                if !(league?.isEditor(user: Auth.auth().currentUser))! {
                    self.present(createBasicAlert(title: "Unable to delete player", message: "Log in to an editor account for this league"), animated: true, completion: nil)
                } else {
                    CornholeFirestore.deletePlayerFromLeague(leagueID: league?.firebaseID ?? League().firebaseID, playerName: league?.players[indexPath.row] ?? "")
                    self.playersTableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        } else {
            
            if editingStyle == .delete {
                if !(league?.isOwner(user: Auth.auth().currentUser))! {
                    self.present(createBasicAlert(title: "Unable to delete editor", message: "Only owners can delete editors"), animated: true, completion: nil)
                } else if indexPath.row == 0 { // can't delete owner
                    self.present(createBasicAlert(title: "Unable to delete editor", message: "Can't delete owner from editors"), animated: true, completion: nil)
                } else {
                    CornholeFirestore.deleteEditorFromLeague(leagueID: league?.firebaseID ?? League().firebaseID, editorEmail: league?.editorEmails[indexPath.row] ?? "")
                    self.editorsTableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
    
    @IBAction func deleteLeague(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure?", message: "This will permanently delete this league and all of its data", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            
            CornholeFirestore.deleteLeague(id: self.league!.firebaseID)
            _ = self.navigationController?.popViewController(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func help(_ sender: Any) {
        self.present(createBasicAlert(title: "Help", message: "Players: Participants in the games (these are not connected to accounts or email addresses)\n\nEditors: Emails of users who can add players or play games for the league\n\nQR: Join this league from another device by scanning this code\n\nOnly the owner (league creator) can add/delete editors"), animated: true, completion: nil)
    }
    
    @IBAction func generateQR(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "\n\n\n\n", preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .default, handler: nil)

        let imgViewTitle = UIImageView(frame: CGRect(x: 90, y: 10, width: 90, height: 90))
        imgViewTitle.image = generateQRCode(from: league!.firebaseID)
        alert.view.addSubview(imgViewTitle)

        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    func first30Launch() -> Bool {
        let alreadyLaunched = UserDefaults.standard.bool(forKey: "alreadyLaunched30LD")
        if alreadyLaunched {
            return false
        } else {
            UserDefaults.standard.set(true, forKey: "alreadyLaunched30LD")
            return true
        }
    }
}
