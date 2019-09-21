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
    var gameSettings = GameSettings()
    
    @IBOutlet var settingsLabel: [UILabel]!
    @IBOutlet var resetMatchesButton: [UIButton]!
    @IBOutlet var editPlayerNameButton: [UIButton]!
    @IBOutlet var versionLabel: [UILabel]!
    @IBOutlet var editInstructionsLabel: [UILabel]!
    @IBOutlet var editStackView: [UIStackView]!
    @IBOutlet var leftArrowButton: [UIButton]!
    @IBOutlet var nameTextField: [UITextField]!
    @IBOutlet var rightArrowButton: [UIButton]!
    @IBOutlet var doneEditingButton: [UIButton]!
    @IBOutlet var firstThrowLabel: [UILabel]!
    @IBOutlet var firstThrowButton: [UIButton]!
    @IBOutlet var gameTypeLabel: [UILabel]!
    @IBOutlet var gameTypeButton: [UIButton]!
    @IBOutlet var setting1Label: [UILabel]!
    @IBOutlet var setting1Stepper: [UIStepper]!
    @IBOutlet var setting2Label: [UILabel]!
    @IBOutlet var setting2Stepper: [UIStepper]!
    
    // background
    @IBOutlet var backgroundImageView: [UIImageView]!
    @IBOutlet weak var portraitView: UIView!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // defaults
        let defaults = UserDefaults.standard
        gameSettings = GameSettings(gameType: GameType(rawValue: defaults.integer(forKey: "gameType")) ?? GameType.standard, winningScore: defaults.integer(forKey: "winningScore"), bustScore: defaults.integer(forKey: "bustScore"), roundLimit: defaults.integer(forKey: "roundLimit"))
        setGameType(gameType: gameSettings.gameType)

        for i in 0..<backgroundImageView.count {
        
            backgroundImageView[i].image = backgroundImage
            
            self.nameTextField[i].delegate = self
            nameTextField[i].autocorrectionType = .no
        
            // get first throw setting
            
            firstThrowWinners = UserDefaults.standard.bool(forKey: "firstThrowWinners")
            if(firstThrowWinners) {
                firstThrowButton[i].setTitle("Winners", for: .normal)
                firstThrowButton[i].setTitle("Winners", for: .selected)
            } else {
                firstThrowButton[i].setTitle("Alternate", for: .normal)
                firstThrowButton[i].setTitle("Alternate", for: .selected)
            }
        
            // version
            
            let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
            let version = nsObject as! String
            versionLabel[i].text = "The Cornhole Scorer Version \(version)"
        
            // devices
            
            if hasTraits(view: self.view, width: UIUserInterfaceSizeClass.regular, height: UIUserInterfaceSizeClass.regular) {
                
                settingsLabel[i].font = UIFont(name: systemFont, size: 75)
                resetMatchesButton[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                editPlayerNameButton[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                editInstructionsLabel[i].font = UIFont(name: systemFont, size: 25)
                nameTextField[i].font = UIFont(name: systemFont, size: 20)
                doneEditingButton[i].titleLabel?.font = UIFont(name: systemFont, size: 25)
                firstThrowLabel[i].font = UIFont(name: systemFont, size: 30)
                firstThrowButton[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                versionLabel[i].font = UIFont(name: systemFont, size: 30)
                gameTypeLabel[i].font = UIFont(name: systemFont, size: 30)
                gameTypeButton[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                setting1Label[i].font = UIFont(name: systemFont, size: 30)
                setting2Label[i].font = UIFont(name: systemFont, size: 30)
                
            } else if smallDevice() {
                
                settingsLabel[i].font = UIFont(name: systemFont, size: 30)
                resetMatchesButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                editPlayerNameButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                editInstructionsLabel[i].font = UIFont(name: systemFont, size: 12)
                nameTextField[i].font = UIFont(name: systemFont, size: 17)
                doneEditingButton[i].titleLabel?.font = UIFont(name: systemFont, size: 15)
                firstThrowLabel[i].font = UIFont(name: systemFont, size: 17)
                firstThrowButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                versionLabel[i].isHidden = true
                gameTypeLabel[i].font = UIFont(name: systemFont, size: 17)
                gameTypeButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                setting1Label[i].font = UIFont(name: systemFont, size: 17)
                setting2Label[i].font = UIFont(name: systemFont, size: 17)

            } else {
                
                settingsLabel[i].font = UIFont(name: systemFont, size: 30)
                resetMatchesButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                editPlayerNameButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                editInstructionsLabel[i].font = UIFont(name: systemFont, size: 15)
                nameTextField[i].font = UIFont(name: systemFont, size: 17)
                doneEditingButton[i].titleLabel?.font = UIFont(name: systemFont, size: 15)
                firstThrowLabel[i].font = UIFont(name: systemFont, size: 17)
                firstThrowButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                versionLabel[i].font = UIFont(name: systemFont, size: 17)
                gameTypeLabel[i].font = UIFont(name: systemFont, size: 17)
                gameTypeButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                setting1Label[i].font = UIFont(name: systemFont, size: 17)
                setting2Label[i].font = UIFont(name: systemFont, size: 17)
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        portraitView.isHidden = UserDefaults.standard.bool(forKey: "isLandscape")
        
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
        for i in 0..<backgroundImageView.count {
            // hide edit menu
            editInstructionsLabel[i].isHidden = true
            editStackView[i].isHidden = true
            doneEditingButton[i].isHidden = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        UserDefaults.standard.set(UIDevice.current.orientation.isLandscape, forKey: "isLandscape")
        
        if tabBarController?.selectedIndex == SETTINGS_TAB_INDEX {
            portraitView.isHidden = UIDevice.current.orientation.isLandscape
            
            if nameTextField[0].isEditing {
                nameTextField[0].resignFirstResponder()
                nameTextField[1].becomeFirstResponder()
            } else if nameTextField[1].isEditing {
                nameTextField[1].resignFirstResponder()
                nameTextField[0].becomeFirstResponder()
            }
        }
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
            
            for i in 0..<backgroundImageView.count {
                // show edit menu
                editInstructionsLabel[i].isHidden = false
                editStackView[i].isHidden = false
                doneEditingButton[i].isHidden = false
                
                nameTextField[i].text = players[editingPlayerIndex]
            }
        }
    }
    
    @IBAction func switchName(_ sender: UIButton) {
        if sender.tag == 1 && editingPlayerIndex != 0 {
            editingPlayerIndex -= 1
        } else if sender.tag == 2 && editingPlayerIndex != players.count - 1 {
            editingPlayerIndex += 1
        }
        editingPlayerName = players[editingPlayerIndex]
        
        for i in 0..<backgroundImageView.count {
            nameTextField[i].text = editingPlayerName
        }
    }
    
    // check if name already taken
    @IBAction func textFieldEditingChanged(_ sender: Any) {
        
        if portraitView.isHidden { // landscape mode
            nameTextField[1].text = nameTextField[0].text
        } else {
            nameTextField[0].text = nameTextField[1].text
        }
        
        for i in 0..<backgroundImageView.count {
            if players.contains(nameTextField[i].text!) {
                nameTextField[i].backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
            } else {
                nameTextField[i].backgroundColor = UIColor.white
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.tag == 0 {
            if !players.contains(nameTextField[0].text!) {
                textField.resignFirstResponder()
                for i in 0..<backgroundImageView.count {
                    nameTextField[i].backgroundColor = UIColor.white
                }
            }
            saveName(doneEditingButton[0])
        }
        
        return true
    }
    
    @IBAction func saveName(_ sender: UIButton) {
        
        // make sure name isn't taken
        
        if !players.contains(nameTextField[0].text!) {
        
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
                                result.setValue(nameTextField[0].text, forKey: "name") // change name
                            }
                        }
                    }
                }
                
                players[editingPlayerIndex] = nameTextField[0].text!
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
                                    newNames[i] = nameTextField[0].text! // change it
                                }
                            }
                            result.setValue(newNames, forKey: "playerNamesArray") // set
                        }
                        
                        // round player names
                        if let rPlayers = result.value(forKey: "roundPlayersArray") as? [String] {
                            var newPlayers = rPlayers
                            for i in 0..<newPlayers.count {
                                if newPlayers[i] == editingPlayerName {
                                    newPlayers[i] = nameTextField[0].text!
                                }
                            }
                            result.setValue(newPlayers, forKey: "roundPlayersArray")
                        }
                    }
                }
            } catch {
                print("Error")
            }
            
            editingPlayerName = nameTextField[0].text!
            
            for i in 0..<backgroundImageView.count {
                // hide edit menu
                editInstructionsLabel[i].isHidden = true
                editStackView[i].isHidden = true
                doneEditingButton[i].isHidden = true
            }
        }
        
        for i in 0..<backgroundImageView.count {
            nameTextField[i].resignFirstResponder() // hide keyboard
        }
    }
    
    // change who throws first
    
    @IBAction func changeFirstThrow(_ sender: Any) {
        firstThrowWinners = !firstThrowWinners
        UserDefaults.standard.set(firstThrowWinners, forKey: "firstThrowWinners")
        
        for i in 0..<backgroundImageView.count {
            if(firstThrowWinners) {
                firstThrowButton[i].setTitle("Winners", for: .normal)
                firstThrowButton[i].setTitle("Winners", for: .selected)
            } else {
                firstThrowButton[i].setTitle("Alternate", for: .normal)
                firstThrowButton[i].setTitle("Alternate", for: .selected)
            }
        }
    }
    
    @IBAction func changeGameType(_ sender: Any) {
        switch gameSettings.gameType {
        case .standard:
            setGameType(gameType: .bust)
        case .bust:
            setGameType(gameType: .rounds)
        case .rounds:
            setGameType(gameType: .standard)
        }
    }
    
    @IBAction func changeSetting1(_ sender: UIStepper) {
        let newValue = Int(sender.value)
        if gameSettings.gameType == .standard || gameSettings.gameType == .bust {
            for i in 0..<backgroundImageView.count {
                setting1Label[i].text = "Winning Score: \(newValue)"
                setting1Stepper[i].value = Double(newValue)
            }
            gameSettings.winningScore = newValue
            UserDefaults.standard.set(newValue, forKey: "winningScore")
        } else if gameSettings.gameType == .rounds {
            for i in 0..<backgroundImageView.count {
                setting1Label[i].text = "# of Rounds: \(newValue)"
                setting1Stepper[i].value = Double(newValue)
            }
            gameSettings.roundLimit = newValue
            UserDefaults.standard.set(newValue, forKey: "roundLimit")
        }
    }
    
    @IBAction func changeSetting2(_ sender: UIStepper) {
        let newValue = Int(sender.value)
        if gameSettings.gameType == .bust {
            for i in 0..<backgroundImageView.count {
                setting2Label[i].text = "Bust Score: \(newValue)"
                setting2Stepper[i].value = Double(newValue)
            }
            gameSettings.bustScore = newValue
            UserDefaults.standard.set(newValue, forKey: "bustScore")
        }
    }
    
    func setGameType(gameType: GameType) {
        let defaults = UserDefaults.standard
        gameSettings.gameType = gameType
        for i in 0..<backgroundImageView.count {
            switch gameType {
            case .standard:
                gameTypeButton[i].setTitle("Standard", for: .normal)
                gameTypeButton[i].setTitle("Standard", for: .selected)
                setting1Label[i].text = "Winning Score: \(gameSettings.winningScore)"
                setting1Stepper[i].value = Double(gameSettings.winningScore)
                setting2Label[i].isHidden = true
                setting2Stepper[i].isHidden = true
                defaults.set(GameType.standard.rawValue, forKey: "gameType")
            case .bust:
                gameTypeButton[i].setTitle("Bust", for: .normal)
                gameTypeButton[i].setTitle("Bust", for: .selected)
                setting1Label[i].text = "Winning Score: \(gameSettings.winningScore)"
                setting1Stepper[i].value = Double(gameSettings.winningScore)
                setting2Label[i].isHidden = false
                setting2Stepper[i].isHidden = false
                setting2Label[i].text = "Bust Score: \(gameSettings.bustScore)"
                setting2Stepper[i].value = Double(gameSettings.bustScore)
                defaults.set(GameType.bust.rawValue, forKey: "gameType")
            case .rounds:
                gameTypeButton[i].setTitle("Rounds", for: .normal)
                gameTypeButton[i].setTitle("Rounds", for: .selected)
                setting1Label[i].text = "# of Rounds: \(gameSettings.roundLimit)"
                setting1Stepper[i].value = Double(gameSettings.roundLimit)
                setting2Label[i].isHidden = true
                setting2Stepper[i].isHidden = true
                defaults.set(GameType.rounds.rawValue, forKey: "gameType")
            }
        }
    }
}
