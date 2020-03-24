//
//  SettingsViewController.swift
//  Cornhole
//
//  Created by Alex Wong on 7/23/18.
//  Copyright © 2018 Kids Can Code. All rights reserved.
//

import UIKit
import CoreData
import FirebaseUI

class SettingsViewController: UIViewController, UITextFieldDelegate, FUIAuthDelegate, DataToSettingsProtocol {
    
    var matches: [Match] = []
    var players: [String] = []
    var editingPlayerIndex: Int = 0 // player currently editing
    var editingPlayerName: String = "" // name of player
    var firstThrowWinners: Bool = false // do winners throw first? (or does it alternate?)
    var gameSettings = GameSettings()
    
    // firebase
    var authUI: FUIAuth?
    var isLoggedIn = false
    
    @IBOutlet var settingsLabel: [UILabel]!
    @IBOutlet var loginButton: [UIButton]!
    @IBOutlet var editLeaguesButton: [UIButton]!
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
    @IBOutlet weak var scrollView: UIScrollView!
    
    // background
    @IBOutlet var backgroundImageView: [UIImageView]!
    @IBOutlet weak var portraitView: UIView!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        // for update to settings
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        // firebase
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth()
        ]
        self.authUI?.providers = providers
        
        if let user = Auth.auth().currentUser {
            loggedIn(user: user)
        }

        for i in 0..<backgroundImageView.count {
        
            backgroundImageView[i].image = backgroundImage
            
            nameTextField[i].delegate = self
            nameTextField[i].autocorrectionType = .no
            nameTextField[i].backgroundColor = .clear
            nameTextField[i].layer.borderColor = UIColor.black.cgColor
        
            // version
            
            let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
            let version = nsObject as! String
            versionLabel[i].text = "The Cornhole Scorer Version \(version)"
        
            // devices
            
            if hasTraits(view: self.view, width: UIUserInterfaceSizeClass.regular, height: UIUserInterfaceSizeClass.regular) {
                
                settingsLabel[i].font = UIFont(name: systemFont, size: 75)
                loginButton[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                editLeaguesButton[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
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
                loginButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                editLeaguesButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
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
                loginButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                editLeaguesButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
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
        
        if !isLeagueActive() {
            // defaults
            updateSettingsFromDefaults()
        } else {
            if let settings = UserDefaults.getActiveLeague()?.gameSettings {
                gameSettings = settings
            }
            if let ftw = UserDefaults.getActiveLeague()?.firstThrowWinners {
                firstThrowWinners = ftw
            }
        }
        reloadPermissions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        portraitView.isHidden = false
        /*
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        view.setNeedsLayout()
        view.layoutIfNeeded()
 */
        AppUtility.lockOrientation(.portrait)
        
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
        }
        
        players = players.sorted()
        for i in 0..<backgroundImageView.count {
            // hide edit menu
            editInstructionsLabel[i].isHidden = true
            editStackView[i].isHidden = true
            doneEditingButton[i].isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollView.flashScrollIndicators()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateLeagueSettings()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        AppUtility.lockOrientation(.all)
    }
    
    func updateSettingsFromDefaults() {
        let defaults = UserDefaults.standard
        firstThrowWinners = UserDefaults.standard.bool(forKey: "firstThrowWinners")
        gameSettings = GameSettings(gameType: GameType(rawValue: defaults.integer(forKey: "gameType")) ?? GameType.standard, winningScore: defaults.integer(forKey: "winningScore"), bustScore: defaults.integer(forKey: "bustScore"), roundLimit: defaults.integer(forKey: "roundLimit"))
    }
    
    @objc func appMovedToBackground() {
        updateLeagueSettings()
    }
    
    func updateLeagueSettings() {
        if isLeagueActive() {
            if let league = UserDefaults.getActiveLeague() {
                if league.gameSettings != gameSettings || league.firstThrowWinners != firstThrowWinners {
                    CornholeFirestore.updateGameSettings(leagueID: league.firebaseID, firstThrowWinners: firstThrowWinners, settings: gameSettings)
                }
            }
        }
    }
    
    func reloadPermissions() {
        var canEdit = false
        if let league = UserDefaults.getActiveLeague() {
            players = league.players
            firstThrowWinners = league.firstThrowWinners
            gameSettings = league.gameSettings
            if let user = Auth.auth().currentUser {
                if league.isEditor(user: user) {
                    canEdit = true
                }
            }
        } else {
            updateSettingsFromDefaults()
            canEdit = true
        }
        for i in 0..<backgroundImageView.count {
            resetMatchesButton[i].isHidden = !canEdit
            editPlayerNameButton[i].isHidden = !canEdit
            firstThrowButton[i].isHidden = !canEdit
            gameTypeLabel[i].isHidden = !canEdit
            gameTypeButton[i].isHidden = !canEdit
            if !canEdit {
                setting1Label[i].isHidden = !canEdit
                setting1Stepper[i].isHidden = !canEdit
                setting2Label[i].isHidden = !canEdit
                setting2Stepper[i].isHidden = !canEdit
                firstThrowLabel[i].text = "Not an editor"
            } else {
                setFirstThrow(winners: firstThrowWinners)
                setGameType(gameType: gameSettings.gameType)
                firstThrowLabel[i].text = "First Tosser:"
            }
        }
    }
    
    func settingsReloadPermissions() {
        reloadPermissions()
    }
    
    // login
    @IBAction func login(_ sender: Any) {
        if !isLoggedIn {
            let authViewController = authUI?.authViewController()
            present(authViewController!, animated: true, completion: nil)
        } else {
            try! authUI?.signOut()
            loggedOut()
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let user = authDataResult?.user {
            loggedIn(user: user)
        }
    }
    
    // what to do when logged in
    func loggedIn(user: User) {
        isLoggedIn = true
        for i in 0..<backgroundImageView.count {
            loginButton[i].setTitle("\(user.email ?? user.uid) (Sign out)", for: .normal)
        }
        reloadPermissions()
    }
    
    // what to do when logged out
    func loggedOut() {
        isLoggedIn = false
        for i in 0..<backgroundImageView.count {
            loginButton[i].setTitle("Log In", for: .normal)
        }
        UserDefaults.setLeagueIDs(ids: [])
        UserDefaults.setActiveLeagueID(id: CornholeFirestore.TEST_LEAGUE_ID)
        CornholeFirestore.forceNextPull()
        updateLeagueSettings()
        reloadPermissions()
    }
    
    @IBAction func editLeagues(_ sender: Any) {
        if isLoggedIn {
            updateLeagueSettings()
            performSegue(withIdentifier: "editLeaguesSegue", sender: nil)
        } else {
            self.present(createBasicAlert(title: "Log In", message: "To create and join leagues, please log in"), animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editLeaguesSegue" {
            let editVC: EditLeaguesViewController = (segue.destination as! UINavigationController).viewControllers.first as! EditLeaguesViewController
            editVC.delegate = self
        }
    }
    
    @IBAction func resetMatches(_ sender: UIButton) {
        // make sure
        let alert = UIAlertController(title: "Are you sure?", message: "This will delete all matches and stats", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            
            if !isLeagueActive() {
                coreDataDeleteAll(entity: "Matches")
            } else {
                CornholeFirestore.deleteAllMatchesFromLeague(leagueID: UserDefaults.getActiveLeagueID()) { (error) in
                    if error != nil {
                        self.present(createBasicAlert(title: "Error", message: "Unable to reset matches. Check your internet connection."), animated: true, completion: nil)
                    }
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: {(action) in
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
                nameTextField[i].backgroundColor = .clear
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
            
            if !isLeagueActive() {
        
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
            } else {
                CornholeFirestore.changePlayerName(leagueID: UserDefaults.getActiveLeagueID(), from: editingPlayerName, to: nameTextField[0].text!) { (error) in
                    if error != nil {
                        self.present(createBasicAlert(title: "Error", message: "Unable to change player name"), animated: true, completion: nil)
                    } else {
                        self.editingPlayerName = self.nameTextField[0].text!
                    }
                }
            }
        }
        
        for i in 0..<backgroundImageView.count {
            // hide edit menu
            editInstructionsLabel[i].isHidden = true
            editStackView[i].isHidden = true
            doneEditingButton[i].isHidden = true
        }
        
        for i in 0..<backgroundImageView.count {
            nameTextField[i].resignFirstResponder() // hide keyboard
        }
    }
    
    // change who throws first
    
    @IBAction func changeFirstThrow(_ sender: Any) {
        firstThrowWinners = !firstThrowWinners
        if !isLeagueActive() {
            UserDefaults.standard.set(firstThrowWinners, forKey: "firstThrowWinners")
        }
        
        setFirstThrow(winners: firstThrowWinners)
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
            if !isLeagueActive() {
                UserDefaults.standard.set(newValue, forKey: "winningScore")
            }
        } else if gameSettings.gameType == .rounds {
            for i in 0..<backgroundImageView.count {
                setting1Label[i].text = "# of Rounds: \(newValue)"
                setting1Stepper[i].value = Double(newValue)
            }
            gameSettings.roundLimit = newValue
            if !isLeagueActive() {
                UserDefaults.standard.set(newValue, forKey: "roundLimit")
            }
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
            if !isLeagueActive() {
                UserDefaults.standard.set(newValue, forKey: "bustScore")
            }
        }
    }
    
    func setFirstThrow(winners: Bool) {
        for i in 0..<backgroundImageView.count {
            if winners {
                firstThrowButton[i].setTitle("Winners", for: .normal)
                firstThrowButton[i].setTitle("Winners", for: .selected)
            } else {
                firstThrowButton[i].setTitle("Alternate", for: .normal)
                firstThrowButton[i].setTitle("Alternate", for: .selected)
            }
        }
    }
    
    func setGameType(gameType: GameType) {
        let defaults = UserDefaults.standard
        gameSettings.gameType = gameType
        for i in 0..<backgroundImageView.count {
            setting1Label[i].isHidden = false
            setting1Stepper[i].isHidden = false
            switch gameType {
            case .standard:
                gameTypeButton[i].setTitle("Standard", for: .normal)
                gameTypeButton[i].setTitle("Standard", for: .selected)
                setting1Label[i].text = "Winning Score: \(gameSettings.winningScore)"
                setting1Stepper[i].value = Double(gameSettings.winningScore)
                setting2Label[i].isHidden = true
                setting2Stepper[i].isHidden = true
                if !isLeagueActive() {
                    defaults.set(GameType.standard.rawValue, forKey: "gameType")
                }
            case .bust:
                gameTypeButton[i].setTitle("Bust", for: .normal)
                gameTypeButton[i].setTitle("Bust", for: .selected)
                setting1Label[i].text = "Winning Score: \(gameSettings.winningScore)"
                setting1Stepper[i].value = Double(gameSettings.winningScore)
                setting2Label[i].isHidden = false
                setting2Stepper[i].isHidden = false
                setting2Label[i].text = "Bust Score: \(gameSettings.bustScore)"
                setting2Stepper[i].value = Double(gameSettings.bustScore)
                if !isLeagueActive() {
                    defaults.set(GameType.bust.rawValue, forKey: "gameType")
                }
            case .rounds:
                gameTypeButton[i].setTitle("Rounds", for: .normal)
                gameTypeButton[i].setTitle("Rounds", for: .selected)
                setting1Label[i].text = "# of Rounds: \(gameSettings.roundLimit)"
                setting1Stepper[i].value = Double(gameSettings.roundLimit)
                setting2Label[i].isHidden = true
                setting2Stepper[i].isHidden = true
                if !isLeagueActive() {
                    defaults.set(GameType.rounds.rawValue, forKey: "gameType")
                }
            }
        }
    }
}
