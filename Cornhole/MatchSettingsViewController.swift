//
//  MatchSettingsViewController.swift
//  Cornhole Scorer
//
//  Created by Alex Wong on 3/25/20.
//  Copyright © 2020 Kids Can Code. All rights reserved.
//

import UIKit
import CoreData

class MatchSettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var match: Match?
    var league: League?
    var players: [String] = []
    var newRed1Name = "Red 1"
    var newBlue1Name = "Blue 1"
    var newRed2Name = "Red 2"
    var newBlue2Name = "Blue 2"
    
    var delegate: MatchSettingsHandler?
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var redPlayer1Label: UILabel!
    @IBOutlet weak var redPlayer1PickerView: UIPickerView!
    @IBOutlet weak var redPlayer2Label: UILabel!
    @IBOutlet weak var redPlayer2PickerView: UIPickerView!
    @IBOutlet weak var bluePlayer1Label: UILabel!
    @IBOutlet weak var bluePlayer1PickerView: UIPickerView!
    @IBOutlet weak var bluePlayer2Label: UILabel!
    @IBOutlet weak var bluePlayer2PickerView: UIPickerView!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backgroundImageView.image = backgroundImage
        
        // display
        
        if bigDevice() {
            
            redPlayer1Label.font = UIFont(name: systemFont, size: 50)
            bluePlayer1Label.font = UIFont(name: systemFont, size: 50)
            redPlayer2Label.font = UIFont(name: systemFont, size: 50)
            bluePlayer2Label.font = UIFont(name: systemFont, size: 50)
            doneButton.titleLabel?.font = UIFont(name: systemFont, size: 50)
            
        } else {
            
            redPlayer1Label.font = UIFont(name: systemFont, size: 25)
            bluePlayer1Label.font = UIFont(name: systemFont, size: 25)
            redPlayer2Label.font = UIFont(name: systemFont, size: 25)
            bluePlayer2Label.font = UIFont(name: systemFont, size: 25)
            doneButton.titleLabel?.font = UIFont(name: systemFont, size: 25)
        }
        
        // set names as if nothing changes
        newRed1Name = (match?.redPlayers[0])!
        newBlue1Name = (match?.bluePlayers[0])!
        newRed2Name = (match?.redPlayers.count)! > 1 ? (match?.redPlayers[1])! : "Red 2"
        newBlue2Name = (match?.bluePlayers.count)! > 1 ? (match?.bluePlayers[1])! : "Blue 2"
        
        // load list of players
        
        players.removeAll()
        
        if !isLeagueActive() {
        
            // core data
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let context = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Players")
            request.returnsObjectsAsFaults = false
            
            // load data
            do {
                let results = try context.fetch(request)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            players.append(name)
                        }
                    }
                }
            } catch {
                print("Error")
            }
        } else {
            players = league!.players
        }
        
        // add other players in match if necessary
        if !players.contains((match?.redPlayers[0])!) {
            players.append((match?.redPlayers[0])!)
        }
        
        if !players.contains((match?.bluePlayers[0])!) {
            players.append((match?.bluePlayers[0])!)
        }
        
        if (match?.redPlayers.count)! > 1 && !players.contains((match?.redPlayers[1])!) {
            players.append((match?.redPlayers[1])!)
        }
        
        if (match?.bluePlayers.count)! > 1 && !players.contains((match?.bluePlayers[1])!) {
            players.append((match?.bluePlayers[1])!)
        }
        
        players = players.sorted()
        
        // update picker views and labels
        
        redPlayer1Label.textColor = match?.redColor
        redPlayer2Label.textColor = match?.redColor
        bluePlayer1Label.textColor = match?.blueColor
        bluePlayer2Label.textColor = match?.blueColor
        
        redPlayer1PickerView.selectRow(players.firstIndex(of: (match?.redPlayers[0])!) ?? players.count, inComponent: 0, animated: false)
        bluePlayer1PickerView.selectRow(players.firstIndex(of: (match?.bluePlayers[0])!) ?? players.count, inComponent: 0, animated: false)
        
        if match?.redPlayers.count == 1 {
            redPlayer2Label.isHidden = true
            redPlayer2PickerView.isHidden = true
            bluePlayer2Label.isHidden = true
            bluePlayer2PickerView.isHidden = true
        } else {
            redPlayer2Label.isHidden = false
            redPlayer2PickerView.isHidden = false
            bluePlayer2Label.isHidden = false
            bluePlayer2PickerView.isHidden = false
            
            redPlayer2PickerView.selectRow(players.firstIndex(of: (match?.redPlayers[1])!)!, inComponent: 0, animated: false)
            bluePlayer2PickerView.selectRow(players.firstIndex(of: (match?.bluePlayers[1])!)!, inComponent: 0, animated: false)
        }
    }
    
    @IBAction func done(_ sender: Any) {
        
        // make sure names are unique
        if match?.redPlayers.count == 1 {
            if newRed1Name == newBlue1Name {
                let alert = UIAlertController(title: "Duplicate names", message: "Make sure all player names are unique", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
        } else {
            if newRed1Name == newBlue1Name ||
                newRed1Name == newRed2Name ||
                newRed1Name == newBlue2Name ||
                newBlue1Name == newRed2Name ||
                newBlue1Name == newBlue2Name ||
                newRed2Name == newBlue2Name {
                let alert = UIAlertController(title: "Duplicate names", message: "Make sure all player names are unique", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
        }
        
        // get old names
        let oldRed1Name: String = (match?.redPlayers[0])!
        let oldBlue1Name: String = (match?.bluePlayers[0])!
        let oldRed2Name: String? = (match?.redPlayers.count)! > 1 ?  match?.redPlayers[1] : nil
        let oldBlue2Name: String? = (match?.bluePlayers.count)! > 1 ?  match?.bluePlayers[1] : nil
        
        if !isLeagueActive() {
            
            // save updated names to core data
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Matches")

            fetchRequest.predicate = NSPredicate(format: "id = %d", match!.id)

            do {
                let results = try context.fetch(fetchRequest) as? [NSManagedObject]
                if let result = results?.first {
                    
                    // player names
                    if let pNames = result.value(forKey: "playerNamesArray") as? [String] {
                        var newNames = pNames
                        for i in 0..<newNames.count {
                            if newNames[i] == oldRed1Name {
                                newNames[i] = newRed1Name
                            } else if newNames[i] == oldBlue1Name {
                                newNames[i] = newBlue1Name
                            } else if oldRed2Name != nil && newNames[i] == oldRed2Name {
                                newNames[i] = newRed2Name
                            } else if oldBlue2Name != nil && newNames[i] == oldBlue2Name {
                                newNames[i] = newBlue2Name
                            }
                        }
                        result.setValue(newNames, forKey: "playerNamesArray")
                    }
                    
                    // round player names
                    if let rPlayers = result.value(forKey: "roundPlayersArray") as? [String] {
                        var newPlayers = rPlayers
                        for i in 0..<newPlayers.count {
                            if newPlayers[i] == oldRed1Name {
                                newPlayers[i] = newRed1Name
                            } else if newPlayers[i] == oldBlue1Name {
                                newPlayers[i] = newBlue1Name
                            } else if oldRed2Name != nil && newPlayers[i] == oldRed2Name {
                                newPlayers[i] = newRed2Name
                            } else if oldBlue2Name != nil && newPlayers[i] == oldBlue2Name {
                                newPlayers[i] = newBlue2Name
                            }
                        }
                        result.setValue(newPlayers, forKey: "roundPlayersArray")
                    }
                }
            } catch {
                print("Fetch Failed: \(error)")
            }

            do {
                try context.save()
               }
            catch {
                print("Saving Core Data Failed: \(error)")
            }
        } else {
            // save to league
            var hasChanged = false
            if oldRed2Name == nil {
                hasChanged = match!.changePlayerNames(froms: [oldRed1Name, oldBlue1Name], tos: [newRed1Name, newBlue1Name])
            } else {
                hasChanged = match!.changePlayerNames(froms: [oldRed1Name, oldBlue1Name, oldRed2Name!, oldBlue2Name!], tos: [newRed1Name, newBlue1Name, newRed2Name, newBlue2Name])
            }
            if hasChanged {
                CornholeFirestore.setLeagueMatches(leagueID: league!.firebaseID, matches: league!.matches)
            }
        }
        
        dismiss(animated: true) {
            self.delegate!.matchSettingsDismissed()
        }
    }
    
    // picker view
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return players.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font? = UIFont(name: systemFont, size: bigDevice() ? 25 : 17)!
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = players[row]
        pickerLabel?.textColor = self.view.tintColor
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 0:
            newRed1Name = players[row]
        case 1:
            newBlue1Name = players[row]
        case 2:
            newRed2Name = players[row]
        case 3:
            newBlue2Name = players[row]
        default:
            break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return bigDevice() ? 40 : 27
    }

}
