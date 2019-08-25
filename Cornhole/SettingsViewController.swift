//
//  SettingsViewController.swift
//  Cornhole
//
//  Created by Alex Wong on 7/23/18.
//  Copyright © 2018 Kids Can Code. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    var matches: [Match] = []
    var players: [String] = []
    var editingPlayerIndex: Int = 0 // player currently editing
    var editingPlayerName: String = "" // name of player
    var firstThrowWinners: Bool = false // do winners throw first? (or does it alternate?)
    
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var resetMatchesButton: UIButton!
    @IBOutlet weak var editPlayerNameButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var editInstructionsLabel: UILabel!
    @IBOutlet weak var editStackView: UIStackView!
    @IBOutlet weak var leftArrowButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var rightArrowButton: UIButton!
    @IBOutlet weak var doneEditingButton: UIButton!
    @IBOutlet weak var firstThrowLabel: UILabel!
    @IBOutlet weak var firstThrowButton: UIButton!
    
    // background
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundImageView.image = backgroundImage
        
        self.nameTextField.delegate = self
        nameTextField.autocorrectionType = .no
        
        // get first throw setting
        
        firstThrowWinners = UserDefaults.standard.bool(forKey: "firstThrowWinners")
        if(firstThrowWinners) {
            firstThrowButton.setTitle("Winners", for: .normal)
            firstThrowButton.setTitle("Winners", for: .selected)
        } else {
            firstThrowButton.setTitle("Alternate", for: .normal)
            firstThrowButton.setTitle("Alternate", for: .selected)
        }
        
        // version
        
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        let version = nsObject as! String
        versionLabel.text = "The Cornhole Scorer Version \(version)"
        
        // devices
        
        if hasTraits(view: self.view, width: UIUserInterfaceSizeClass.regular, height: UIUserInterfaceSizeClass.regular) {
            
            settingsLabel.font = UIFont(name: systemFont, size: 75)
            resetMatchesButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            editPlayerNameButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            editInstructionsLabel.font = UIFont(name: systemFont, size: 25)
            nameTextField.font = UIFont(name: systemFont, size: 20)
            doneEditingButton.titleLabel?.font = UIFont(name: systemFont, size: 25)
            firstThrowLabel.font = UIFont(name: systemFont, size: 30)
            firstThrowButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            versionLabel.font = UIFont(name: systemFont, size: 30)
            
        } else if smallDevice() {
            
            settingsLabel.font = UIFont(name: systemFont, size: 30)
            resetMatchesButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            editPlayerNameButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            editInstructionsLabel.font = UIFont(name: systemFont, size: 12)
            nameTextField.font = UIFont(name: systemFont, size: 17)
            doneEditingButton.titleLabel?.font = UIFont(name: systemFont, size: 15)
            firstThrowLabel.font = UIFont(name: systemFont, size: 17)
            firstThrowButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            versionLabel.font = UIFont(name: systemFont, size: 17)

        } else {
            
            settingsLabel.font = UIFont(name: systemFont, size: 30)
            resetMatchesButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            editPlayerNameButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            editInstructionsLabel.font = UIFont(name: systemFont, size: 15)
            nameTextField.font = UIFont(name: systemFont, size: 17)
            doneEditingButton.titleLabel?.font = UIFont(name: systemFont, size: 15)
            firstThrowLabel.font = UIFont(name: systemFont, size: 17)
            firstThrowButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            versionLabel.font = UIFont(name: systemFont, size: 17)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        players.removeAll()
        
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
        
        players = players.sorted()
        
        // hide edit menu
        editInstructionsLabel.isHidden = true
        editStackView.isHidden = true
        doneEditingButton.isHidden = true
    }

    @IBAction func resetMatches(_ sender: UIButton) {
        // make sure
        let alert = UIAlertController(title: "Are you sure?", message: "This will delete all matches and stats", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            
            coreDataDeleteAll(entity: "Matches")
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func editPlayerName(_ sender: UIButton) {
        
        if players.count > 0 { // if there are players to edit
            
            editingPlayerIndex = 0
            editingPlayerName = players[0]
            
            // show edit menu
            editInstructionsLabel.isHidden = false
            editStackView.isHidden = false
            doneEditingButton.isHidden = false
            
            nameTextField.text = players[editingPlayerIndex]
        }
    }
    
    @IBAction func switchName(_ sender: UIButton) {
        if sender.tag == 1 && editingPlayerIndex != 0 {
            editingPlayerIndex -= 1
        } else if sender.tag == 2 && editingPlayerIndex != players.count - 1 {
            editingPlayerIndex += 1
        }
        editingPlayerName = players[editingPlayerIndex]
        nameTextField.text = editingPlayerName
    }
    
    // check if name already taken
    @IBAction func textFieldEditingChanged(_ sender: Any) {
        if players.contains(nameTextField.text!) {
            nameTextField.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        } else {
            nameTextField.backgroundColor = UIColor.white
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.tag == 0 {
            if !players.contains(nameTextField.text!) {
                textField.resignFirstResponder()
            }
            saveName(doneEditingButton)
        }
        
        return true
    }
    
    @IBAction func saveName(_ sender: UIButton) {
        
        // make sure name isn't taken
        
        if !players.contains(nameTextField.text!) {
        
            // core data
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let context = appDelegate.persistentContainer.viewContext
            
            let playerRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Players")
            playerRequest.returnsObjectsAsFaults = false
            
            // load data
            do {
                let results = try context.fetch(playerRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            if name == editingPlayerName {
                                result.setValue(nameTextField.text, forKey: "name") // change name
                            }
                        }
                    }
                }
                
                players[editingPlayerIndex] = nameTextField.text!
            } catch {
                print("Error")
            }
            
            // update matches
            
            let matchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Matches")
            matchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(matchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        
                        // player names
                        if let pNames = result.value(forKey: "playerNamesArray") as? [String] { // get player names
                            var newNames = pNames
                            for i in 0..<newNames.count {
                                if newNames[i] == editingPlayerName { // if names match
                                    newNames[i] = nameTextField.text! // change it
                                }
                            }
                            result.setValue(newNames, forKey: "playerNamesArray") // set
                        }
                        
                        // round player names
                        if let rPlayers = result.value(forKey: "roundPlayersArray") as? [String] {
                            var newPlayers = rPlayers
                            for i in 0..<newPlayers.count {
                                if newPlayers[i] == editingPlayerName {
                                    newPlayers[i] = nameTextField.text!
                                }
                            }
                            result.setValue(newPlayers, forKey: "roundPlayersArray")
                        }
                    }
                }
            } catch {
                print("Error")
            }
            
            editingPlayerName = nameTextField.text!
            
            // hide edit menu
            editInstructionsLabel.isHidden = true
            editStackView.isHidden = true
            doneEditingButton.isHidden = true
        }
        
        nameTextField.resignFirstResponder() // hide keyboard
    }
    
    // change who throws first
    
    @IBAction func changeFirstThrow(_ sender: Any) {
        firstThrowWinners = !firstThrowWinners
        UserDefaults.standard.set(firstThrowWinners, forKey: "firstThrowWinners")
        
        if(firstThrowWinners) {
            firstThrowButton.setTitle("Winners", for: .normal)
            firstThrowButton.setTitle("Winners", for: .selected)
        } else {
            firstThrowButton.setTitle("Alternate", for: .normal)
            firstThrowButton.setTitle("Alternate", for: .selected)
        }
    }
    
}
