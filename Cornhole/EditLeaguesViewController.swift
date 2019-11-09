//
//  EditLeaguesViewController.swift
//  Cornhole Scorer
//
//  Created by Alex Wong on 10/12/19.
//  Copyright © 2019 Kids Can Code. All rights reserved.
//

import UIKit

class EditLeaguesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var leagues: [League] = []
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var leaguesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backgroundImageView.image = backgroundImage
        let leagueIDs: [Int] = UserDefaults.getLeagueIDs()
        for id in leagueIDs {
            CornholeFirestore.pullLeague(id: id) { (league, error) in
                if let error = error {
                    print("Error: \(error)")
                } else {
                    self.leagues.append(league!)
                    self.leaguesTableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createLeague(_ sender: Any) {
        let alert = UIAlertController(title: "Create League", message: "Enter the league name", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if textField?.text != "" {
                let newLeague = League(name: textField!.text!)
                newLeague.getNewID(completion: { (error) in
                    if error == nil {
                        self.leagues.append(newLeague)
                        self.leaguesTableView.reloadData()
                        CornholeFirestore.createLeague(collection: "leagues", name: newLeague.name, id: newLeague.id)
                        var oldIDs = UserDefaults.getLeagueIDs()
                        oldIDs.append(newLeague.id)
                        UserDefaults.setLeagueIDs(ids: oldIDs)
                        self.openDetail(indexPath: IndexPath(row: self.leagues.count - 1, section: 0))
                    }
                })
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func joinLeague(_ sender: Any) {
        let alert = UIAlertController(title: "Join League", message: "Enter the league ID", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField { (textField) in
            textField.placeholder = "ID"
        }
        alert.addAction(UIAlertAction(title: "Join", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if textField?.text != "" {
                // this is all wrong
                let newLeague = League(name: textField!.text!)
                newLeague.getNewID(completion: { (error) in
                    if error == nil {
                        self.leagues.append(newLeague)
                        self.leaguesTableView.reloadData()
                        CornholeFirestore.createLeague(collection: "leagues", name: newLeague.name, id: newLeague.id)
                        self.openDetail(indexPath: IndexPath(row: self.leagues.count - 1, section: 0))
                    }
                })
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leagues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leagueCell")!
        cell.textLabel?.text = leagues[indexPath.row].name
        return cell
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
