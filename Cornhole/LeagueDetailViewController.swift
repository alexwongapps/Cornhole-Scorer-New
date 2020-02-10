//
//  LeagueDetailViewController.swift
//  Cornhole Scorer
//
//  Created by Alex Wong on 10/12/19.
//  Copyright © 2019 Kids Can Code. All rights reserved.
//

import UIKit

class LeagueDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var league: League?
    
    @IBOutlet weak var playersTableView: UITableView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var playersLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backgroundImageView.image = backgroundImage
        idLabel.text = "ID: \(league?.id ?? League.NEW_ID_FAILED)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if hasTraits(view: self.view, width: UIUserInterfaceSizeClass.regular, height: UIUserInterfaceSizeClass.regular) {
            
            idLabel.font = UIFont(name: systemFont, size: 30)
            playersLabel.font = UIFont(name: systemFont, size: 30)
            addButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
        } else if smallDevice() {
            idLabel.font = UIFont(name: systemFont, size: 17)
            playersLabel.font = UIFont(name: systemFont, size: 17)
            addButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
        } else {
            idLabel.font = UIFont(name: systemFont, size: 17)
            playersLabel.font = UIFont(name: systemFont, size: 17)
            addButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
        }
    }
    
    @IBAction func addPlayer(_ sender: Any) {
        let alert = UIAlertController(title: "Add Player", message: "Enter the player's name", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if textField?.text != "" {
                let newPlayer = textField!.text!
                if (self.league?.players.contains(newPlayer))! {
                    let repeatAlert = UIAlertController(title: "Invalid name", message: "\(newPlayer) already in league", preferredStyle: .alert)
                    repeatAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.self.present(repeatAlert, animated: true, completion: nil)
                } else {
                    self.league?.players.append(newPlayer)
                    self.playersTableView.reloadData()
                    CornholeFirestore.addPlayerToLeague(leagueID: self.league?.id ?? League.NEW_ID_FAILED, playerName: newPlayer)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (league?.players.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaguePlayerCell")!
        cell.textLabel!.text = league?.players[indexPath.row]
        cell.backgroundColor = .clear
        
        // fonts
        if hasTraits(view: self.view, width: UIUserInterfaceSizeClass.regular, height: UIUserInterfaceSizeClass.regular) {
            
            cell.textLabel!.font = UIFont(name: systemFont, size: 30)
        } else if smallDevice() {
            cell.textLabel!.font = UIFont(name: systemFont, size: 17)
        } else {
            cell.textLabel!.font = UIFont(name: systemFont, size: 17)
        }
        
        return cell
    }
    
    // delete player name
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            activityIndicator.startAnimating()
            CornholeFirestore.deletePlayerFromLeague(leagueID: league?.id ?? League().id, playerName: league?.players[indexPath.row] ?? "") { (err) in
                self.activityIndicator.stopAnimating()
                if let err = err {
                    print("error deleting player: \(err)")
                    self.present(createBasicAlert(title: "Error", message: "Unable to delete player. Check your internet connection."), animated: true, completion: nil)
                } else {
                    self.league?.players.remove(at: indexPath.row)
                    self.playersTableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
}
