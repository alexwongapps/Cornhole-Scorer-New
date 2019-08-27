//
//  FirstViewController.swift
//  Cornhole
//
//  Created by Alex Wong on 7/2/18.
//  Copyright © 2018 Kids Can Code. All rights reserved.
//

import UIKit
import CoreData
import WebKit
import StoreKit

class ScoreboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WKUIDelegate, WKNavigationDelegate, UITextFieldDelegate {
    
    //////////////////////////////////////////////////////
    // Login Page ////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    var maxBags = 4 // bags thrown per team per round
    
    var players: [String] = [] // list of saved players
    var oneVOne: Bool = true // is the match 1v1 or 2v2
    var trackingStats: Bool = true // are we tracking stats in this match
    var buttonSelect: Int = 0 // which select button was clicked
    
    // player names
    var redPlayer1: String = ""
    var redPlayer2: String = ""
    var bluePlayer1: String = ""
    var bluePlayer2: String = ""
    
    // match data
    var startDate: Date?
    var redColor: UIColor = UIColor.red
    var blueColor: UIColor = UIColor.blue
    
    // outlets
    @IBOutlet var selectPlayersLabel: [UILabel]!
    @IBOutlet var playersSegmentedControl: [UISegmentedControl]!
    @IBOutlet var swapColorsButton: [UIButton]!
    @IBOutlet var teamRedLabel: [UILabel]!
    @IBOutlet var redPlayer1Label: [UILabel]!
    @IBOutlet var redPlayer2Label: [UILabel]!
    @IBOutlet var redPlayer1Button: [UIButton]!
    @IBOutlet var redPlayer2Button: [UIButton]!
    @IBOutlet var teamBlueLabel: [UILabel]!
    @IBOutlet var bluePlayer1Label: [UILabel]!
    @IBOutlet var bluePlayer2Label: [UILabel]!
    @IBOutlet var bluePlayer1Button: [UIButton]!
    @IBOutlet var bluePlayer2Button: [UIButton]!
    @IBOutlet var trackingStatsButton: [UIButton]!
    @IBOutlet weak var selectExistingPlayerLabel: UILabel!
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var createNewPlayerLabel: UILabel!
    @IBOutlet weak var newPlayerTextField: UITextField!
    @IBOutlet weak var addNewPlayerButton: UIButton!
    @IBOutlet var playButton: [UIButton]!
    @IBOutlet var sePlayButton: [UIButton]! // for iphone se
    @IBOutlet var helpButton: [UIButton]!
    @IBOutlet var rulesButton: [UIButton]!
    
    // login view outlet
    @IBOutlet weak var gameViewPortrait: UIView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginViewPortrait: UIView!
    
    // team name labels on game view
    @IBOutlet weak var redTeamLabel: UILabel!
    @IBOutlet weak var blueTeamLabel: UILabel!
    
    // backgrounds
    @IBOutlet var gameBackgroundImageView: [UIImageView]!
    @IBOutlet var loginBackgroundImageView: [UIImageView]!
    
    // close login view/play button
    @IBAction func hideLogin(_ sender: Any) {
        
        for i in 0..<help0Label.count {
            // reset player select button colors
            redPlayer1Button[i].setTitleColor(self.view.tintColor, for: .normal)
            redPlayer2Button[i].setTitleColor(self.view.tintColor, for: .normal)
            bluePlayer1Button[i].setTitleColor(self.view.tintColor, for: .normal)
            bluePlayer2Button[i].setTitleColor(self.view.tintColor, for: .normal)
        }
        
        // set player 1 names
        redPlayer1 = redPlayer1Label[0].text!
        bluePlayer1 = bluePlayer1Label[0].text!
        
        // set first thrower
        firstThrowerColor = Match.RED
        firstThrowerPlayer1 = true
        
        // set if game is 1v1 or 2v2
        if playersSegmentedControl[0].selectedSegmentIndex == 0 {
            oneVOne = true
            redTeamLabel.text = "\(redPlayer1) •"
            blueTeamLabel.text = "✕ \(bluePlayer1)"
        } else {
            oneVOne = false
            redPlayer2 = redPlayer2Label[0].text!
            bluePlayer2 = bluePlayer2Label[0].text!
            redTeamLabel.text = "\(redPlayer1) •\n\(redPlayer2)"
            blueTeamLabel.text = "✕ \(bluePlayer1)\n\(bluePlayer2)"
        }
        
        // read max bags text field
        maxBags = 4
        
        // set match data
        startDate = Date()
        
        // set colors
        redTotalScoreLabel.textColor = redColor
        redTeamLabel.textColor = redColor
        redRoundScoreLabel.textColor = redColor
        redOnLabel.textColor = redColor
        redInLabel.textColor = redColor
        redOnStepper.tintColor = redColor
        redInStepper.tintColor = redColor
        
        blueTotalScoreLabel.textColor = blueColor
        blueTeamLabel.textColor = blueColor
        blueRoundScoreLabel.textColor = blueColor
        blueOnLabel.textColor = blueColor
        blueInLabel.textColor = blueColor
        blueOnStepper.tintColor = blueColor
        blueInStepper.tintColor = blueColor
        
        loginView.isHidden = true
        // animateCloseLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        gameViewPortrait.isHidden = UIDevice.current.orientation.isLandscape
        loginViewPortrait.isHidden = UIDevice.current.orientation.isLandscape
        helpViewPortrait.isHidden = UIDevice.current.orientation.isLandscape
        
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
        
        showSelectPlayerMenu(show: false)
        playerTableView.reloadData()
        
        for i in 0..<help0Label.count {
            redPlayer1Button[i].setTitleColor(self.view.tintColor, for: .normal)
            redPlayer2Button[i].setTitleColor(self.view.tintColor, for: .normal)
            bluePlayer1Button[i].setTitleColor(self.view.tintColor, for: .normal)
            bluePlayer2Button[i].setTitleColor(self.view.tintColor, for: .normal)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if tabBarController?.selectedIndex == SCOREBOARD_TAB_INDEX {
            gameViewPortrait.isHidden = UIDevice.current.orientation.isLandscape
            loginViewPortrait.isHidden = UIDevice.current.orientation.isLandscape
            helpViewPortrait.isHidden = UIDevice.current.orientation.isLandscape
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // coreDataDeleteAll(entity: "Matches")
        
        let appearance = UITabBarItem.appearance()
        let attributes = [NSAttributedString.Key.font: UIFont(name: systemFont, size: hasTraits(view: self.view, width: UIUserInterfaceSizeClass.regular, height: UIUserInterfaceSizeClass.regular) ? 17 : 12)]
        appearance.setTitleTextAttributes(attributes as Any as? [NSAttributedString.Key : Any], for: .normal)
        
        var segmentFont = UIFont(name: systemFont, size: 14)
        
        let redTeamLabelHeightConstraint = redTeamLabel.heightAnchor.constraint(equalToConstant: 150)
        let blueTeamLabelHeightConstraint = blueTeamLabel.heightAnchor.constraint(equalToConstant: 150)
        let playerTableViewWidthConstraint = playerTableView.widthAnchor.constraint(equalToConstant: 270)
        playerTableViewWidthConstraint.isActive = true // handles warning
        
        redTeamLabelHeightConstraint.isActive = true
        blueTeamLabelHeightConstraint.isActive = true
        
        // adjust for size classes/small devices
        
        // size classes
        if hasTraits(view: self.view, width: UIUserInterfaceSizeClass.regular, height: UIUserInterfaceSizeClass.regular) { // big device
            
            for i in 0..<help0Label.count {
                
                // help view
                help0Label[i].font = UIFont(name: systemFont, size: 50)
                help1Label[i].font = UIFont(name: systemFont, size: 20)
                help2Label[i].font = UIFont(name: systemFont, size: 20)
                help3Label[i].font = UIFont(name: systemFont, size: 25)
                help4Label[i].font = UIFont(name: systemFont, size: 23)
                help5Label[i].font = UIFont(name: systemFont, size: 20)
                help6Label[i].font = UIFont(name: systemFont, size: 20)
                help7Label[i].font = UIFont(name: systemFont, size: 25)
                help8Label[i].font = UIFont(name: systemFont, size: 20)
                help9Label[i].font = UIFont(name: systemFont, size: 20)
                help10Label[i].font = UIFont(name: systemFont, size: 20)
                help11Label[i].font = UIFont(name: systemFont, size: 20)
                
                // login view
                
                segmentFont = UIFont(name: systemFont, size: 30)
                
                selectPlayersLabel[i].font = UIFont(name: systemFont, size: 75)
                teamRedLabel[i].font = UIFont(name: systemFont, size: 30)
                redPlayer1Label[i].font = UIFont(name: systemFont, size: 30)
                redPlayer2Label[i].font = UIFont(name: systemFont, size: 30)
                teamBlueLabel[i].font = UIFont(name: systemFont, size: 30)
                bluePlayer1Label[i].font = UIFont(name: systemFont, size: 30)
                bluePlayer2Label[i].font = UIFont(name: systemFont, size: 30)
                
                helpButton[i].titleLabel?.font = UIFont(name: systemFont, size: 45)
                rulesButton[i].titleLabel?.font = UIFont(name: systemFont, size: 45)
                swapColorsButton[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                redPlayer1Button[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                redPlayer2Button[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                bluePlayer1Button[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                bluePlayer2Button[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                playButton[i].titleLabel?.font = UIFont(name: systemFont, size: 50)
                trackingStatsButton[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                
                // constraints
                playersSegmentedControl[i].heightAnchor.constraint(equalToConstant: 50).isActive = true
            }
            
            selectExistingPlayerLabel.font = UIFont(name: systemFont, size: 25)
            
            createNewPlayerLabel.font = UIFont(name: systemFont, size: 20)
            newPlayerTextField.font = UIFont(name: systemFont, size: 20)
            addNewPlayerButton.titleLabel?.font = UIFont(name: systemFont, size: 25)
            
            
            playerTableView.widthAnchor.constraint(equalToConstant: 400).isActive = true
            playerTableViewWidthConstraint.isActive = false
            
            // game view
            
            totalLabel.font = UIFont(name: systemFont, size: 100)
            redTeamLabel.font = UIFont(name: systemFont, size: 25)
            blueTeamLabel.font = UIFont(name: systemFont, size: 25)
            redTotalScoreLabel.font = UIFont(name: systemFont, size: 225)
            blueTotalScoreLabel.font = UIFont(name: systemFont, size: 225)
            totalDashLabel.font = UIFont(name: systemFont, size: 225)
            roundLabel.font = UIFont(name: systemFont, size: 50)
            redRoundScoreLabel.font = UIFont(name: systemFont, size: 100)
            blueRoundScoreLabel.font = UIFont(name: systemFont, size: 100)
            roundDashLabel.font = UIFont(name: systemFont, size: 120)
            redInLabel.font = UIFont(name: systemFont, size: 30)
            redOnLabel.font = UIFont(name: systemFont, size: 30)
            blueInLabel.font = UIFont(name: systemFont, size: 30)
            blueOnLabel.font = UIFont(name: systemFont, size: 30)
            
            selectNewPlayersButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            roundCompleteButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            undoButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            resetButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            
            // constraints
            redTeamLabel.heightAnchor.constraint(equalToConstant: 250).isActive = true
            redTeamLabelHeightConstraint.isActive = false
            blueTeamLabel.heightAnchor.constraint(equalToConstant: 250).isActive = true
            blueTeamLabelHeightConstraint.isActive = false
            
        } else if smallDevice() {
            
            for i in 0..<help0Label.count {
                
                // help view
                help0Label[i].font = UIFont(name: systemFont, size: 30)
                help1Label[i].font = UIFont(name: systemFont, size: 12)
                help2Label[i].font = UIFont(name: systemFont, size: 11)
                help3Label[i].font = UIFont(name: systemFont, size: 16)
                help4Label[i].font = UIFont(name: systemFont, size: 17)
                help5Label[i].font = UIFont(name: systemFont, size: 12)
                help6Label[i].font = UIFont(name: systemFont, size: 12)
                help7Label[i].font = UIFont(name: systemFont, size: 16)
                help8Label[i].font = UIFont(name: systemFont, size: 14)
                help9Label[i].font = UIFont(name: systemFont, size: 12)
                help10Label[i].font = UIFont(name: systemFont, size: 12)
                help11Label[i].font = UIFont(name: systemFont, size: 12)
                help6Label[i].textAlignment = .left
                help9Label[i].textAlignment = .right
                
                // login view
                
                segmentFont = UIFont(name: systemFont, size: 11)
                
                selectPlayersLabel[i].font = UIFont(name: systemFont, size: 20)
                teamRedLabel[i].font = UIFont(name: systemFont, size: 14)
                redPlayer1Label[i].font = UIFont(name: systemFont, size: 14)
                redPlayer2Label[i].font = UIFont(name: systemFont, size: 14)
                teamBlueLabel[i].font = UIFont(name: systemFont, size: 14)
                bluePlayer1Label[i].font = UIFont(name: systemFont, size: 14)
                bluePlayer2Label[i].font = UIFont(name: systemFont, size: 14)
                
                helpButton[i].titleLabel?.font = UIFont(name: systemFont, size: 15)
                rulesButton[i].titleLabel?.font = UIFont(name: systemFont, size: 15)
                swapColorsButton[i].titleLabel?.font = UIFont(name: systemFont, size: 14)
                redPlayer1Button[i].titleLabel?.font = UIFont(name: systemFont, size: 14)
                redPlayer2Button[i].titleLabel?.font = UIFont(name: systemFont, size: 14)
                bluePlayer1Button[i].titleLabel?.font = UIFont(name: systemFont, size: 14)
                bluePlayer2Button[i].titleLabel?.font = UIFont(name: systemFont, size: 14)
                trackingStatsButton[i].titleLabel?.font = UIFont(name: systemFont, size: 15)
                sePlayButton[i].titleLabel?.font = UIFont(name: systemFont, size: 15)
                sePlayButton[i].isHidden = false
                
                // constraints
                playersSegmentedControl[i].heightAnchor.constraint(equalToConstant: 23).isActive = true
                trackingStatsButton[i].widthAnchor.constraint(equalToConstant: 180).isActive = true
            }
            
            selectExistingPlayerLabel.font = UIFont(name: systemFont, size: 14)
            
            createNewPlayerLabel.font = UIFont(name: systemFont, size: 12)
            newPlayerTextField.font = UIFont(name: systemFont, size: 14)
            addNewPlayerButton.titleLabel?.font = UIFont(name: systemFont, size: 14)
            
            selectExistingPlayerLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
            playerTableView.widthAnchor.constraint(equalToConstant: 220).isActive = true
            playerTableViewWidthConstraint.isActive = false
            
            // game view
            
            redTeamLabel.font = UIFont(name: systemFont, size: 14)
            blueTeamLabel.font = UIFont(name: systemFont, size: 14)
            redTotalScoreLabel.font = UIFont(name: systemFont, size: 80)
            blueTotalScoreLabel.font = UIFont(name: systemFont, size: 80)
            totalDashLabel.font = UIFont(name: systemFont, size: 80)
            redInLabel.font = UIFont(name: systemFont, size: 14)
            redOnLabel.font = UIFont(name: systemFont, size: 14)
            blueInLabel.font = UIFont(name: systemFont, size: 14)
            blueOnLabel.font = UIFont(name: systemFont, size: 14)
            
            selectNewPlayersButton.titleLabel?.font = UIFont(name: systemFont, size: 12.5)
            roundCompleteButton.titleLabel?.font = UIFont(name: systemFont, size: 12.5)
            undoButton.titleLabel?.font = UIFont(name: systemFont, size: 12.5)
            resetButton.titleLabel?.font = UIFont(name: systemFont, size: 11)
        
            totalLabel.font = UIFont(name: systemFont, size: 40)
            seTotalDashLabel.font = UIFont(name: systemFont, size: 100)
            
            totalLabel.text = "Score"
            redRoundScoreLabel.isHidden = true
            blueRoundScoreLabel.isHidden = true
            roundDashLabel.isHidden = true
            roundLabel.isHidden = true
            seTotalDashLabel.isHidden = false
            totalDashLabel.isHidden = true
            
            // constraints
            redTeamLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
            redTeamLabelHeightConstraint.isActive = false
            blueTeamLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
            blueTeamLabelHeightConstraint.isActive = false
            
        } else { // normal phone
            
            for i in 0..<help0Label.count {
                
                // help view
                help0Label[i].font = UIFont(name: systemFont, size: 30)
                help1Label[i].font = UIFont(name: systemFont, size: 12)
                help2Label[i].font = UIFont(name: systemFont, size: 12)
                help3Label[i].font = UIFont(name: systemFont, size: 16)
                help4Label[i].font = UIFont(name: systemFont, size: 18)
                help5Label[i].font = UIFont(name: systemFont, size: 12)
                help6Label[i].font = UIFont(name: systemFont, size: 12)
                help7Label[i].font = UIFont(name: systemFont, size: 16)
                help8Label[i].font = UIFont(name: systemFont, size: 14)
                help9Label[i].font = UIFont(name: systemFont, size: 12)
                help10Label[i].font = UIFont(name: systemFont, size: 12)
                help11Label[i].font = UIFont(name: systemFont, size: 12)
                
                // login view
                
                segmentFont = UIFont(name: systemFont, size: 14)
                
                selectPlayersLabel[i].font = UIFont(name: systemFont, size: 30)
                teamRedLabel[i].font = UIFont(name: systemFont, size: 17)
                redPlayer1Label[i].font = UIFont(name: systemFont, size: 17)
                redPlayer2Label[i].font = UIFont(name: systemFont, size: 17)
                teamBlueLabel[i].font = UIFont(name: systemFont, size: 17)
                bluePlayer1Label[i].font = UIFont(name: systemFont, size: 17)
                bluePlayer2Label[i].font = UIFont(name: systemFont, size: 17)
                
                helpButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                rulesButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                swapColorsButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                redPlayer1Button[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                redPlayer2Button[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                bluePlayer1Button[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                bluePlayer2Button[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                playButton[i].titleLabel?.font = UIFont(name: systemFont, size: 20)
                trackingStatsButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                
                playersSegmentedControl[i].heightAnchor.constraint(equalToConstant: 28).isActive = true
            }

            selectExistingPlayerLabel.font = UIFont(name: systemFont, size: 17)
            
            createNewPlayerLabel.font = UIFont(name: systemFont, size: 12)
            newPlayerTextField.font = UIFont(name: systemFont, size: 14)
            addNewPlayerButton.titleLabel?.font = UIFont(name: systemFont, size: 14)
            
            // game view
            
            totalLabel.font = UIFont(name: systemFont, size: 40)
            redTeamLabel.font = UIFont(name: systemFont, size: 17)
            blueTeamLabel.font = UIFont(name: systemFont, size: 17)
            redTotalScoreLabel.font = UIFont(name: systemFont, size: 150)
            blueTotalScoreLabel.font = UIFont(name: systemFont, size: 150)
            totalDashLabel.font = UIFont(name: systemFont, size: 150)
            roundLabel.font = UIFont(name: systemFont, size: 25)
            redRoundScoreLabel.font = UIFont(name: systemFont, size: 60)
            blueRoundScoreLabel.font = UIFont(name: systemFont, size: 60)
            roundDashLabel.font = UIFont(name: systemFont, size: 60)
            redInLabel.font = UIFont(name: systemFont, size: 17)
            redOnLabel.font = UIFont(name: systemFont, size: 17)
            blueInLabel.font = UIFont(name: systemFont, size: 17)
            blueOnLabel.font = UIFont(name: systemFont, size: 17)
            
            selectNewPlayersButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            roundCompleteButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            undoButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            resetButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            
        }
        
        // set backgrounds

        for i in 0..<help0Label.count {
            
            playersSegmentedControl[i].setTitleTextAttributes([NSAttributedString.Key.font: segmentFont!], for: .normal)
            
            gameBackgroundImageView[i].image = backgroundImage
            loginBackgroundImageView[i].image = backgroundImage
            
            if firstLaunch() {
                help(helpButton[i])
                UserDefaults.standard.set(true, forKey: "firstThrowWinners") // initialize setting for who throws first, winners or alternating
            }
        }
        
        playerTableView.backgroundColor = .clear
 
        helpView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        
        self.newPlayerTextField.delegate = self
        newPlayerTextField.autocorrectionType = .no
    }

    // dtermine if stats are tracked or not
    @IBAction func changeStatsTracking(_ sender: UIButton) {
        trackingStats = !trackingStats
        for i in 0..<help0Label.count {
            if trackingStats {
                trackingStatsButton[i].setTitle("Tracking Stats: On", for: .normal)
            } else {
                trackingStatsButton[i].setTitle("Tracking Stats: Off", for: .normal)
            }
        }
    }
    
    // table view
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return players.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "playerCell")
        cell.backgroundColor = .clear
        if hasTraits(view: loginView, width: UIUserInterfaceSizeClass.regular, height: UIUserInterfaceSizeClass.regular) {
            cell.textLabel?.font = UIFont(name: systemFont, size: 25)
        } else if smallDevice() {
            cell.textLabel?.font = UIFont(name: systemFont, size: 14)
        } else {
            cell.textLabel?.font = UIFont(name: systemFont, size: 17)
        }
        cell.textLabel?.text = players[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    // row clicked
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // hide select player menu
        showSelectPlayerMenu(show: false)
        
        for i in 0..<help0Label.count {
            
            // choose appropriate name
            switch buttonSelect {
                
            case 1:
                redPlayer1Label[i].text = players[indexPath.row]
                redPlayer1Button[i].setTitleColor(self.view.tintColor, for: .normal)
                break
                
            case 2:
                redPlayer2Label[i].text = players[indexPath.row]
                redPlayer2Button[i].setTitleColor(self.view.tintColor, for: .normal)
                break
                
            case 3:
                bluePlayer1Label[i].text = players[indexPath.row]
                bluePlayer1Button[i].setTitleColor(self.view.tintColor, for: .normal)
                break
                
            case 4:
                bluePlayer2Label[i].text = players[indexPath.row]
                bluePlayer2Button[i].setTitleColor(self.view.tintColor, for: .normal)
                break
                
            default:
                break
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // delete player name
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Players")
            request.returnsObjectsAsFaults = false
            
            // delete
            do {
                let results = try context.fetch(request)
                
                for result in results as! [NSManagedObject] {
                    if result.value(forKey: "name") as! String == players[indexPath.row] {
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
                players.remove(at: indexPath.row)
                playerTableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                let saveError = error as NSError
                print(saveError)
            }
        }
    }
    
    // check if name already taken
    @IBAction func textFieldEditingChanged(_ sender: Any) {
        if players.contains(newPlayerTextField.text!) {
            newPlayerTextField.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        } else {
            newPlayerTextField.backgroundColor = UIColor.white
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.tag == 0 {
            if !players.contains(newPlayerTextField.text!) {
                textField.resignFirstResponder()
            }
            addNewPlayer(addNewPlayerButton!)
        }
        
        return true
    }
    
    // add new player with button
    @IBAction func addNewPlayer(_ sender: Any) {
        
        // make sure name isn't taken
        
        if !players.contains(newPlayerTextField.text!) {
        
            // resign keyboard
            view.endEditing(true)
            
            // save player
            if newPlayerTextField.text != "" && !players.contains(newPlayerTextField.text!) {
                players.append(newPlayerTextField.text!)
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                let context = appDelegate.persistentContainer.viewContext
                
                let newUser = NSEntityDescription.insertNewObject(forEntityName: "Players", into: context)
                newUser.setValue(newPlayerTextField.text, forKey: "name")
                
                do {
                    try context.save()
                    print("Saved")
                } catch {
                    print("Error")
                }
            }
            
            showSelectPlayerMenu(show: false)
            
            for i in 0..<help0Label.count {
                
                // edit appropriate name
                switch buttonSelect {
                    
                case 1:
                    redPlayer1Label[i].text = newPlayerTextField.text
                    redPlayer1Button[i].setTitleColor(self.view.tintColor, for: .normal)
                    break
                    
                case 2:
                    redPlayer2Label[i].text = newPlayerTextField.text
                    redPlayer2Button[i].setTitleColor(self.view.tintColor, for: .normal)
                    break
                    
                case 3:
                    bluePlayer1Label[i].text = newPlayerTextField.text
                    bluePlayer1Button[i].setTitleColor(self.view.tintColor, for: .normal)
                    break
                    
                case 4:
                    bluePlayer2Label[i].text = newPlayerTextField.text
                    bluePlayer2Button[i].setTitleColor(self.view.tintColor, for: .normal)
                    break
                    
                default:
                    break
                    
                }
            }
            
            playerTableView.reloadData()
            newPlayerTextField.text = ""
        }
    }
    
    // change 1v1/2v2
    @IBAction func changeNumPlayers(_ sender: UISegmentedControl) {
        if sender.tag == 0 { // landscape pressed
            playersSegmentedControl[1].selectedSegmentIndex = playersSegmentedControl[0].selectedSegmentIndex
        } else {
            playersSegmentedControl[0].selectedSegmentIndex = playersSegmentedControl[1].selectedSegmentIndex
        }
        if playersSegmentedControl[0].selectedSegmentIndex == 1 {
            for i in 0..<help0Label.count {
                redPlayer2Label[i].isHidden = false
                bluePlayer2Label[i].isHidden = false
                redPlayer2Button[i].isHidden = false
                bluePlayer2Button[i].isHidden = false
            }
        } else {
            for i in 0..<help0Label.count {
                redPlayer2Label[i].isHidden = true
                bluePlayer2Label[i].isHidden = true
                redPlayer2Button[i].isHidden = true
                bluePlayer2Button[i].isHidden = true
            }
        }
    }
    
    // change colors
    @IBAction func swapColors(_ sender: UIButton) {
        
        for i in 0..<help0Label.count {
            
            let teamRedText = teamRedLabel[i].text
            let teamRedColor = teamRedLabel[i].textColor
            
            teamRedLabel[i].text = teamBlueLabel[i].text
            teamRedLabel[i].textColor = teamBlueLabel[i].textColor
            redPlayer1Label[i].textColor = teamBlueLabel[i].textColor
            redPlayer2Label[i].textColor = teamBlueLabel[i].textColor
            
            teamBlueLabel[i].text = teamRedText
            teamBlueLabel[i].textColor = teamRedColor
            bluePlayer1Label[i].textColor = teamRedColor
            bluePlayer2Label[i].textColor = teamRedColor
            
        }
        
        // maybe change later
        if redColor == UIColor.red {
            redColor = UIColor.blue
            blueColor = UIColor.red
        } else {
            blueColor = UIColor.blue
            redColor = UIColor.red
        }
    }
    
    // open select player dialog
    @IBAction func selectPlayer(_ sender: UIButton) {
        showSelectPlayerMenu(show: true)
        
        buttonSelect = sender.tag
        
        let selectedColor: UIColor = UIColor.purple
        
        for i in 0..<help0Label.count {
            redPlayer1Button[i].setTitleColor((redPlayer1Button[i].tag == buttonSelect) ? selectedColor :  self.view.tintColor, for: .normal)
            redPlayer2Button[i].setTitleColor((redPlayer2Button[i].tag == buttonSelect) ? selectedColor :  self.view.tintColor, for: .normal)
            bluePlayer1Button[i].setTitleColor((bluePlayer1Button[i].tag == buttonSelect) ? selectedColor :  self.view.tintColor, for: .normal)
            bluePlayer2Button[i].setTitleColor((bluePlayer2Button[i].tag == buttonSelect) ? selectedColor :  self.view.tintColor, for: .normal)
        }
    }
    
    // web
    @IBAction func displayRules(_ sender: UIButton) {
        if let url = URL(string: "http://www.playcornhole.org/pages/rules/") {
            UIApplication.shared.open(url)
        }
    }
 
    @IBAction func help(_ sender: UIButton) {
        helpState = 1
        helpView.isHidden = false
        
        helpView.layer.mask = nil
        helpViewPortrait.layer.mask = nil
        
        for i in 0..<help0Label.count {
            help0Label[i].isHidden = false
            help0Label[i].text = "Welcome to Cornhole!\n\nTap to go through instructions"
        }
    }
    
    // show menu
    func showSelectPlayerMenu(show: Bool) {
        selectExistingPlayerLabel.isHidden = !show
        playerTableView.isHidden = !show
        createNewPlayerLabel.isHidden = !show
        newPlayerTextField.isHidden = !show
        addNewPlayerButton.isHidden = !show
    }
    
    //////////////////////////////////////////////////////
    // Help //////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var helpViewPortrait: UIView!
    @IBOutlet var help0Label: [UILabel]!
    @IBOutlet var help1Label: [UILabel]!
    @IBOutlet var help2Label: [UILabel]!
    @IBOutlet var help3Label: [UILabel]!
    @IBOutlet var help4Label: [UILabel]!
    @IBOutlet var help5Label: [UILabel]!
    @IBOutlet var help6Label: [UILabel]!
    @IBOutlet var help7Label: [UILabel]!
    @IBOutlet var help8Label: [UILabel]!
    @IBOutlet var help9Label: [UILabel]!
    @IBOutlet var help10Label: [UILabel]!
    @IBOutlet var help11Label: [UILabel]!
    
    var helpState = 0
    
    // move through help menu
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
        
        if helpView.isHidden == true {
            helpState = 0
        }
        
        switch helpState {
        case 0:
        break
            
        case 1:
            createHole(inView: helpView, aroundView: playersSegmentedControl[0])
            createHole(inView: helpViewPortrait, aroundView: playersSegmentedControl[1])
            
            for i in 0..<help0Label.count {
                help0Label[i].isHidden = true
                help1Label[i].isHidden = false
                help1Label[i].text = "Select game mode here\n"
            }
            helpState += 1
        break
            
        case 2:
            createHole(inView: helpView, aroundView: redPlayer1Button[0])
            createHole(inView: helpViewPortrait, aroundView: redPlayer1Button[1])
            
            for i in 0..<help0Label.count {
                help1Label[i].isHidden = true
                help2Label[i].isHidden = false
            }
            helpState += 1
        break
            
        case 3:
            createHole(inView: helpView, aroundView: newPlayerTextField)
            
            showSelectPlayerMenu(show: true)
            
            for i in 0..<help0Label.count {
                help2Label[i].isHidden = true
                help3Label[i].isHidden = false
            }
            helpState += 1
        break
            
        case 4:
            createHole(inView: helpView, aroundView: playerTableView)
            
            for i in 0..<help0Label.count {
                help3Label[i].isHidden = true
                help4Label[i].isHidden = false
                help4Label[i].text = "Or select it from the list.\n\nFor 2v2, players standing physically next to each other should be the same player number for their respective teams."
            }
            helpState += 1
        break
            
        case 5:
            createHole(inView: helpView, aroundView: trackingStatsButton[0])
            createHole(inView: helpViewPortrait, aroundView: trackingStatsButton[1])
            
            showSelectPlayerMenu(show: false)
            
            for i in 0..<help0Label.count {
                help4Label[i].isHidden = true
                help5Label[i].isHidden = false
                help5Label[i].text = "Click this toggle to set whether or not you want to track stats from this game\n"
            }
            helpState += 1
        break
            
        case 6:
            if smallDevice() {
                createHole(inView: helpView, aroundView: sePlayButton[0])
                createHole(inView: helpViewPortrait, aroundView: sePlayButton[1])
            } else {
                createHole(inView: helpView, aroundView: playButton[0])
                createHole(inView: helpViewPortrait, aroundView: playButton[1])
            }
            
            for i in 0..<help0Label.count {
                help5Label[i].isHidden = true
                help6Label[i].isHidden = false
                help6Label[i].text = "When you're done, press play\n"
            }
            helpState += 1
        break
            
        case 7:
            createHoleIPad(inView: helpView, aroundView: stepperStackView)
            
            loginView.isHidden = true
            
            for i in 0..<help0Label.count {
                help6Label[i].isHidden = true
                help7Label[i].isHidden = false
            }
            helpState += 1
        break
            
        case 8:
            createHoleIPad(inView: helpView, aroundView: roundCompleteButton)
            
            for i in 0..<help0Label.count {
                help7Label[i].isHidden = true
                help8Label[i].isHidden = false
                help8Label[i].text = "Click Round Complete after all bags for the round have been thrown\n"
            }
            helpState += 1
        break
            
        case 9:
            createHoleIPad(inView: helpView, aroundView: resetButton)
            
            for i in 0..<help0Label.count {
                help8Label[i].isHidden = true
                help9Label[i].isHidden = false
                help9Label[i].text = "Click Reset/Restart to restart the game with the same players\n"
            }
            helpState += 1
        break
            
        case 10:
            createHoleIPad(inView: helpView, aroundView: selectNewPlayersButton)
            
            for i in 0..<help0Label.count {
                help9Label[i].isHidden = true
                help10Label[i].isHidden = false
                help10Label[i].text = "Click Select New Players to restart the game with different players\n"
            }
            helpState += 1
        break
            
        case 11:
            createHoleIPad(inView: helpView, aroundView: redTeamLabel)
            
            for i in 0..<help0Label.count {
                help10Label[i].isHidden = true
                help11Label[i].isHidden = false
            }
            helpState += 1
        break
            
        case 12:
            for i in 0..<help0Label.count {
                help11Label[i].isHidden = true
            }
            loginView.isHidden = false
            helpView.isHidden = true
            helpState = 0
        break
            
        default:
        break
        }
    }
    
    func createHole(inView: UIView, aroundView: UIView) {
        let path = CGMutablePath()
        path.addRect(CGRect(x: aroundView.frame.origin.x, y: aroundView.frame.origin.y, width: aroundView.frame.width, height: aroundView.frame.height))
        path.addRect(CGRect(origin: .zero, size: inView.frame.size))
        
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
        inView.layer.mask = maskLayer
        inView.clipsToBounds = true
    }
    
    func createHoleIPad(inView: UIView, aroundView: UIView) {
        let path = CGMutablePath()
        path.addRect(CGRect(x: aroundView.frame.origin.x, y: aroundView.frame.origin.y - self.view.safeAreaInsets.top, width: aroundView.frame.width, height: aroundView.frame.height))
        path.addRect(CGRect(origin: .zero, size: inView.frame.size))
        
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
        inView.layer.mask = maskLayer
        inView.clipsToBounds = true
    }
    
    func animateCloseLogin() {
        var loginViewFrame = loginView.frame
        loginViewFrame.origin.x = UIScreen.main.bounds.origin.x
        loginView.frame = loginViewFrame
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
            
            loginViewFrame.origin.x = UIScreen.main.bounds.origin.x - UIScreen.main.bounds.width
            
            self.loginView.frame = loginViewFrame
        }, completion: { finished in
            self.loginView.isHidden = true
            print("animated")
        })
    }
    
    func animateOpenLogin() {
        var loginViewFrame = self.loginView.frame
        loginViewFrame.origin.x -= UIScreen.main.bounds.width
        loginView.frame = loginViewFrame
        loginView.isHidden = false
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
            loginViewFrame.origin.x = UIScreen.main.bounds.origin.x
            
            self.loginView.frame = loginViewFrame
        }, completion: { finished in
            print("animated")
        })
    }
    
    //////////////////////////////////////////////////////
    // Scoreboard ////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    // scores
    var redTotalScore = 0
    var blueTotalScore = 0
    var redRoundScore = 0
    var blueRoundScore = 0
    
    var round = 1 // round number
    var rounds: [Round] = []
    
    // first throw
    var firstThrowerColor = Match.RED
    var firstThrowerPlayer1: Bool = true // useful for doubles
    
    // used for undo
    var lastRedScore = 0
    var lastBlueScore = 0
    
    // outlets
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var redTotalScoreLabel: UILabel!
    @IBOutlet weak var totalDashLabel: UILabel!
    @IBOutlet weak var blueTotalScoreLabel: UILabel!
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var redRoundScoreLabel: UILabel!
    @IBOutlet weak var roundDashLabel: UILabel!
    @IBOutlet weak var blueRoundScoreLabel: UILabel!
    @IBOutlet weak var redInLabel: UILabel!
    @IBOutlet weak var redInStepper: UIStepper!
    @IBOutlet weak var redOnLabel: UILabel!
    @IBOutlet weak var redOnStepper: UIStepper!
    @IBOutlet weak var blueInLabel: UILabel!
    @IBOutlet weak var blueInStepper: UIStepper!
    @IBOutlet weak var blueOnLabel: UILabel!
    @IBOutlet weak var blueOnStepper: UIStepper!
    @IBOutlet weak var selectNewPlayersButton: UIButton!
    @IBOutlet weak var roundCompleteButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var seTotalDashLabel: UILabel!
    @IBOutlet weak var stepperStackView: UIStackView!
    
    // stepper clicked
    @IBAction func stepperChanged(_ sender: UIStepper) {
        
        // calculate round scores
        redRoundScore = Int(redInStepper.value * 3 + redOnStepper.value)
        blueRoundScore = Int(blueInStepper.value * 3 + blueOnStepper.value)
        redRoundScoreLabel.text = "\(redRoundScore)"
        blueRoundScoreLabel.text = "\(blueRoundScore)"
        
        // update labels
        redInLabel.text = "In: \(Int(redInStepper.value))"
        redOnLabel.text = "On: \(Int(redOnStepper.value))"
        blueInLabel.text = "In: \(Int(blueInStepper.value))"
        blueOnLabel.text = "On: \(Int(blueOnStepper.value))"
        
        // update steppers to not exceed bag count
        let redThrown = Int(redInStepper.value + redOnStepper.value)
        let blueThrown = Int(blueInStepper.value + blueOnStepper.value)
        
        redInStepper.maximumValue = Double(maxBags - redThrown + Int(redInStepper.value))
        redOnStepper.maximumValue = Double(maxBags - redThrown + Int(redOnStepper.value))
        blueInStepper.maximumValue = Double(maxBags - blueThrown + Int(blueInStepper.value))
        blueOnStepper.maximumValue = Double(maxBags - blueThrown + Int(blueOnStepper.value))
    }
    
    // round done
    @IBAction func roundComplete(_ sender: UIButton) {
        
        // remember throwers
        lastFirstThrowerColor = firstThrowerColor
        
        // add round to rounds array
        let redIn = Int(redInStepper.value)
        let redOn = Int(redOnStepper.value)
        let redOff = maxBags - redIn - redOn
        let blueIn = Int(blueInStepper.value)
        let blueOn = Int(blueOnStepper.value)
        let blueOff = maxBags - blueIn - blueOn
        
        rounds.append(Round(red: Board(bagsIn: redIn, bagsOn: redOn, bagsOff: redOff), blue: Board(bagsIn: blueIn, bagsOn: blueOn, bagsOff: blueOff), redPlayer: getCurrentPlayers()[0], bluePlayer: getCurrentPlayers()[1]))
        
        // prep for next undo
        lastRedScore = redTotalScore
        lastBlueScore = blueTotalScore
        
        // update total score
        if redRoundScore > blueRoundScore {
            redTotalScore += redRoundScore - blueRoundScore
        } else {
            blueTotalScore += blueRoundScore - redRoundScore
        }
        
        redTotalScoreLabel.text = "\(redTotalScore)"
        blueTotalScoreLabel.text = "\(blueTotalScore)"
        
        // reset round score
        redRoundScore = 0
        blueRoundScore = 0
        
        redRoundScoreLabel.text = "\(redRoundScore)"
        blueRoundScoreLabel.text = "\(blueRoundScore)"
        
        // reset steppers
        resetSteppers()
        
        // update first tosser
        round += 1
        
        // change first toss display
        printFirstToss(undoing: false)
        
        // show undo button
        undoButton.isHidden = false
        
        // check for win
        if matchComplete() {
            
            // reviews
            
            let userCalendar = Calendar.current
            var fourthOfJulyDateComponents = DateComponents()
            fourthOfJulyDateComponents.year = 2019
            fourthOfJulyDateComponents.month = 7
            fourthOfJulyDateComponents.day = 4
            fourthOfJulyDateComponents.hour = 5
            fourthOfJulyDateComponents.timeZone = TimeZone(abbreviation: "PDT")
            let fourthOfJulyDate = userCalendar.date(from: fourthOfJulyDateComponents)!
            let currentDate = Date()
            
            let defaults = UserDefaults.standard
            var timesPlayed = defaults.integer(forKey: "timesPlayed")
            timesPlayed += 1
            defaults.set(timesPlayed, forKey: "timesPlayed")
            
            var hasAskedForReview = defaults.bool(forKey: "hasAskedForReview")
            
            if timesPlayed >= 3 && currentDate > fourthOfJulyDate && !hasAskedForReview {
                if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                }
                hasAskedForReview = true
            }
            
            defaults.set(hasAskedForReview, forKey: "hasAskedForReview")
            
            // everything else
            
            resetButton.setTitle("Restart", for: .normal)
            
            // determine winner
            if redTotalScore >= 21 {
                roundCompleteButton.setTitle("\(COLORS[redColor]!) Wins!", for: .normal)
                roundCompleteButton.setTitleColor(redColor, for: .normal)
            } else {
                roundCompleteButton.setTitle("\(COLORS[blueColor]!) Wins!", for: .normal)
                roundCompleteButton.setTitleColor(blueColor, for: .normal)
            }
            
            // disable features
            redInStepper.isEnabled = false
            redOnStepper.isEnabled = false
            blueInStepper.isEnabled = false
            blueOnStepper.isEnabled = false
            roundCompleteButton.isEnabled = false
            
            undoButton.isHidden = true
            
            // save match if tracking stats
            if trackingStats {
                // create match object
                var lastMatch: Match?
                
                // manage id
                Match.universalID = getNewID(matches: getMatchesFromCoreData())
            
                if oneVOne {
                    lastMatch = Match(redPlayers: [redPlayer1], bluePlayers: [bluePlayer1], rounds: rounds)
                } else {
                    lastMatch = Match(redPlayers: [redPlayer1, redPlayer2], bluePlayers: [bluePlayer1, bluePlayer2], rounds: rounds)
                }
                
                print("Match \(lastMatch!.id)")
            
                // save match data core data
            
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
            
                let newUser = NSEntityDescription.insertNewObject(forEntityName: "Matches", into: context)
                
                let allPlayers: [String] = (lastMatch?.redPlayers)! + (lastMatch?.bluePlayers)!
                newUser.setValue(allPlayers, forKey: "playerNamesArray")
            
                var roundPlayers: [String] = []
                var roundData: [Int] = [] // red in, red on, red off, blue in, blue on, blue off
            
                for round in 0..<(lastMatch?.rounds)!.count {
                    roundPlayers.append((lastMatch?.rounds[round].redPlayer)!)
                    roundPlayers.append((lastMatch?.rounds[round].bluePlayer)!)
                    
                    // add board data
                    roundData.append((lastMatch?.rounds[round].red.bagsIn)!)
                    roundData.append((lastMatch?.rounds[round].red.bagsOn)!)
                    roundData.append((lastMatch?.rounds[round].red.bagsOff)!)
                    roundData.append((lastMatch?.rounds[round].blue.bagsIn)!)
                    roundData.append((lastMatch?.rounds[round].blue.bagsOn)!)
                    roundData.append((lastMatch?.rounds[round].blue.bagsOff)!)
                }
                newUser.setValue(roundPlayers, forKey: "roundPlayersArray")
                newUser.setValue(roundData, forKey: "roundDataArray")
                newUser.setValue(lastMatch?.id, forKey: "id")
                newUser.setValue(startDate, forKey: "startDate")
                newUser.setValue(Date(), forKey: "endDate")
                newUser.setValue(redColor, forKey: "redColor")
                newUser.setValue(blueColor, forKey: "blueColor")
            
                do {
                    try context.save()
                    print("Saved")
                } catch {
                    print("Error")
                }
            }
        }
    }
    
    var userSure = false // used for select new players & reset
    
    // go back to login screen
    func selectNewPlayers() {
        
        loginView.isHidden = false
        // animateOpenLogin()
        
        // reset screen
        reset()
        showSelectPlayerMenu(show: false)
        
        for i in 0..<help0Label.count {
            redPlayer1Label[i].text = "Player 1"
            redPlayer2Label[i].text = "Player 2"
            bluePlayer1Label[i].text = "Player 1"
            bluePlayer2Label[i].text = "Player 2"
        }
    }
    
    // undo last round
    @IBAction func undo(_ sender: UIButton) {
        // reset scores
        redTotalScore = lastRedScore
        blueTotalScore = lastBlueScore
        
        redTotalScoreLabel.text = "\(redTotalScore)"
        blueTotalScoreLabel.text = "\(blueTotalScore)"
        
        // backup round
        round -= 1
        rounds.removeLast()
        printFirstToss(undoing: true)
        
        undoButton.isHidden = true
    }
    
    
    @IBAction func resetAlert(_ sender: UIButton) {
        
        if !matchComplete() {
            // make sure
            let alert = UIAlertController(title: "Are you sure?", message: "This will delete all data from this game", preferredStyle: UIAlertController.Style.alert)
        
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {(action) in
                alert.dismiss(animated: true, completion: nil)
                
                if sender.tag == 0 { // select new players
                    self.selectNewPlayers()
                } else if sender.tag == 1 { // reset
                    self.reset()
                }
                
            }))
        
            alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: {(action) in
                alert.dismiss(animated: true, completion: nil)
            }))
        
            self.present(alert, animated: true, completion: nil)
        } else {
            if sender.tag == 0 { // select new players
                self.selectNewPlayers()
            } else if sender.tag == 1 { // reset
                self.reset()
            }
        }
    }
    
    // reset game (same players)
    func reset() {
        
        // reset date
        startDate = Date()
        
        // reset first thrower
        firstThrowerColor = Match.RED
        firstThrowerPlayer1 = true
        
        // reset round
        round = 1
        rounds.removeAll()
        printFirstToss(undoing: false)
    
        // clear scores
    
        redTotalScore = 0
        blueTotalScore = 0
    
        redTotalScoreLabel.text = "\(redTotalScore)"
        blueTotalScoreLabel.text = "\(blueTotalScore)"
    
        redRoundScore = 0
        blueRoundScore = 0
    
        redRoundScoreLabel.text = "\(redRoundScore)"
        blueRoundScoreLabel.text = "\(blueRoundScore)"
    
        // update buttons
    
        roundCompleteButton.setTitle("Round Complete", for: .normal)
        roundCompleteButton.setTitleColor(self.view.tintColor, for: .normal)
    
        resetButton.setTitle("Reset", for: .normal)
    
        // reenable steppers
        redInStepper.isEnabled = true
        redOnStepper.isEnabled = true
        blueInStepper.isEnabled = true
        blueOnStepper.isEnabled = true
    
        roundCompleteButton.isEnabled = true
    
        // reset undo
        undoButton.isHidden = true
        lastRedScore = 0
        lastBlueScore = 0
    
        resetSteppers()
    }
    
    // set steppers to 0
    func resetSteppers() {
        redInStepper.value = 0
        redOnStepper.value = 0
        blueInStepper.value = 0
        blueOnStepper.value = 0
        
        redInStepper.maximumValue = Double(maxBags)
        redOnStepper.maximumValue = Double(maxBags)
        blueInStepper.maximumValue = Double(maxBags)
        blueOnStepper.maximumValue = Double(maxBags)
        
        // update labels
        redInLabel.text = "In: \(Int(redInStepper.value))"
        redOnLabel.text = "On: \(Int(redOnStepper.value))"
        blueInLabel.text = "In: \(Int(blueInStepper.value))"
        blueOnLabel.text = "On: \(Int(blueOnStepper.value))"
    }
    
    // returns [red, blue]
    func getCurrentPlayers() -> [String] {
        if oneVOne {
            return [redPlayer1, bluePlayer1]
        } else {
            if round % 2 == 1 {
                return [redPlayer1, bluePlayer1]
            } else {
                return [redPlayer2, bluePlayer2]
            }
        }
    }
    
    func matchComplete() -> Bool {
        return redTotalScore >= 21 || blueTotalScore >= 21
    }
    
    // remember first tosser of previous round
    var lastFirstThrowerColor = Match.RED
    
    // print tossers
    func printFirstToss(undoing: Bool) {
        
        let firstThrowWinners: Bool = UserDefaults.standard.bool(forKey: "firstThrowWinners")
        
        // if first throw alternates
        if(!firstThrowWinners) {
            if oneVOne {
                if round % 2 == 1 { // red team going
                    firstThrowerColor = Match.RED
                    firstThrowerPlayer1 = true
                } else {
                    firstThrowerColor = Match.BLUE
                    firstThrowerPlayer1 = true
                }
            } else {
                if round % 4 == 1 { // red first going
                    firstThrowerColor = Match.RED
                    firstThrowerPlayer1 = true
                } else if round % 4 == 2 { // red second going
                    firstThrowerColor = Match.RED
                    firstThrowerPlayer1 = false
                } else if round % 4 == 3 { // blue first going
                    firstThrowerColor = Match.BLUE
                    firstThrowerPlayer1 = true
                } else { // blue second going
                    firstThrowerColor = Match.BLUE
                    firstThrowerPlayer1 = false
                }
            }
        } else { // if the round winners throw first
            
            if(rounds.count == 0) { // first round
                firstThrowerColor = Match.RED
                firstThrowerPlayer1 = true
            } else { // not first round
            
                if(!undoing) {
                    // set winner as first thrower
                    if(rounds[rounds.count - 1].winner == Match.RED) {
                        firstThrowerColor = Match.RED
                    } else if(rounds[rounds.count - 1].winner == Match.BLUE) {
                        firstThrowerColor = Match.BLUE
                    }
                } else { // if undoing
                    firstThrowerColor = lastFirstThrowerColor
                }
                
                // if no one wins, first thrower stays the same
                
                // switch player 1/2 for doubles
                if(!oneVOne) {
                    firstThrowerPlayer1 = !firstThrowerPlayer1
                }
            }
            
        }
        
        // write labels
        if oneVOne {
            if firstThrowerColor == Match.RED { // red team going
                redTeamLabel.text = "\(redPlayer1) •"
                blueTeamLabel.text = "✕ \(bluePlayer1)"
            } else { // blue team going
                redTeamLabel.text = "\(redPlayer1) ✕"
                blueTeamLabel.text = "• \(bluePlayer1)"
            }
        } else {
            if(firstThrowerColor == Match.RED && firstThrowerPlayer1) { // red player 1
                redTeamLabel.text = "\(redPlayer1) •\n\(redPlayer2)"
                blueTeamLabel.text = "✕ \(bluePlayer1)\n\(bluePlayer2)"
            } else if(firstThrowerColor == Match.RED) { // red player 2
                redTeamLabel.text = "\(redPlayer1)\n\(redPlayer2) •"
                blueTeamLabel.text = "\(bluePlayer1)\n✕ \(bluePlayer2)"
            } else if(firstThrowerPlayer1) { // blue player 1
                redTeamLabel.text = "\(redPlayer1) ✕\n\(redPlayer2)"
                blueTeamLabel.text = "• \(bluePlayer1)\n\(bluePlayer2)"
            } else { // blue player 2
                redTeamLabel.text = "\(redPlayer1)\n\(redPlayer2) ✕"
                blueTeamLabel.text = "\(bluePlayer1)\n• \(bluePlayer2)"
            }
        }
    }
    
    func firstLaunch() -> Bool {
        let alreadyLaunched = UserDefaults.standard.bool(forKey: "alreadyLaunched")
        if alreadyLaunched {
            return false
        } else {
            UserDefaults.standard.set(true, forKey: "alreadyLaunched")
            return true
        }
    }
}

