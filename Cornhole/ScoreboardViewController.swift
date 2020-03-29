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
import Firebase

class ScoreboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WKUIDelegate, WKNavigationDelegate, UITextFieldDelegate, SelectColorViewControllerDelegate {
    
    //////////////////////////////////////////////////////
    // Login Page ////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    var maxBags = 4 // bags thrown per team per round
    
    var players: [String] = [] // list of saved players
    var oneVOne: Bool = true // is the match 1v1 or 2v2
    var trackingStats: Bool = true // are we tracking stats in this match
    var buttonSelect: Int = 0 // which select button was clicked
    
    var league: League?
    
    // player names
    var redPlayer1: String = ""
    var redPlayer2: String = ""
    var bluePlayer1: String = ""
    var bluePlayer2: String = ""
    
    // match data
    var startDate: Date?
    var redColor: UIColor = UIColor.red
    var blueColor: UIColor = UIColor.blue
    var gameSettings: GameSettings = GameSettings()
    
    // alert
    var alert30: UIAlertController?
    
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
    @IBOutlet var selectExistingPlayerLabel: [UILabel]!
    @IBOutlet var playerTableView: [UITableView]!
    @IBOutlet var createNewPlayerLabel: [UILabel]!
    @IBOutlet var newPlayerTextField: [UITextField]!
    @IBOutlet var addNewPlayerButton: [UIButton]!
    @IBOutlet var playButton: [UIButton]!
    @IBOutlet var sePlayButton: [UIButton]! // for iphone se
    @IBOutlet var helpButton: [UIButton]!
    @IBOutlet var rulesButton: [UIButton]!
    @IBOutlet var changeRedButton: [UIButton]!
    @IBOutlet var changeBlueButton: [UIButton]!
    @IBOutlet var activityIndicator: [UIActivityIndicatorView]!
    
    // login view outlet
    @IBOutlet weak var gameViewPortrait: UIView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginViewPortrait: UIView!
    
    // team name labels on game view
    @IBOutlet var redTeamLabel: [UILabel]!
    @IBOutlet var blueTeamLabel: [UILabel]!
    
    // backgrounds
    @IBOutlet var gameBackgroundImageView: [UIImageView]!
    @IBOutlet var loginBackgroundImageView: [UIImageView]!
    
    // close login view/play button
    @IBAction func hideLogin(_ sender: Any) {
        
        if isLeagueActive() {
            
            // get league
            
            if (league?.isEditor(user: Auth.auth().currentUser))! {
                self.startMatch()
            } else {
                self.present(createBasicAlert(title: "Not an authorized player", message: "Please log in to an editor account for this league"), animated: true, completion: nil)
            }
        } else {
            startMatch()
        }
    }
    
    func startMatch() {
        setGameSettings()
        
        for i in 0..<help0Label.count {
            // round label
            if gameSettings.gameType == .rounds {
                roundLabel[i].text = "Round 1/\(gameSettings.roundLimit)"
            } else {
                roundLabel[i].text = "Round"
            }
            
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
            
            for i in 0..<help0Label.count {
                redTeamLabel[i].text = "\(redPlayer1) •"
                blueTeamLabel[i].text = "✕ \(bluePlayer1)"
            }
        } else {
            oneVOne = false
            redPlayer2 = redPlayer2Label[0].text!
            bluePlayer2 = bluePlayer2Label[0].text!
            
            for i in 0..<help0Label.count {
                redTeamLabel[i].text = "\(redPlayer1) •\n\(redPlayer2)"
                blueTeamLabel[i].text = "✕ \(bluePlayer1)\n\(bluePlayer2)"
            }
        }
        
        // read max bags text field
        maxBags = 4
        
        // set match data
        startDate = Date()
        
        for i in 0..<help0Label.count {
            // set colors
            redTotalScoreLabel[i].textColor = redColor
            redRoundScoreLabel[i].textColor = redColor
            redTeamLabel[i].textColor = redColor
            redOnLabel[i].textColor = redColor
            redInLabel[i].textColor = redColor
            redOnStepper[i].tintColor = redColor
            redInStepper[i].tintColor = redColor
            
            blueTotalScoreLabel[i].textColor = blueColor
            blueRoundScoreLabel[i].textColor = blueColor
            blueTeamLabel[i].textColor = blueColor
            blueOnLabel[i].textColor = blueColor
            blueInLabel[i].textColor = blueColor
            blueOnStepper[i].tintColor = blueColor
            blueInStepper[i].tintColor = blueColor
        }
        
        loginView.isHidden = true
        // animateCloseLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("active league: \(UserDefaults.getActiveLeagueID())")
        
        super.viewWillAppear(animated)
        
        gameViewPortrait.isHidden = UserDefaults.standard.bool(forKey: "isLandscape")
        loginViewPortrait.isHidden = UserDefaults.standard.bool(forKey: "isLandscape")

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
            
            players = players.sorted()
        } else {
            if let league = UserDefaults.getActiveLeague() {
                self.league = league
                self.players = league.players
                self.players = self.players.sorted()
                for i in 0..<self.help0Label.count {
                    self.playerTableView[i].reloadData()
                }
            } else {
                self.present(createBasicAlert(title: "Error", message: "Unable to pull league \(UserDefaults.getActiveLeagueID())"), animated: true, completion: nil)
            }
        }
        
        showSelectPlayerMenu(show: false)
        
        for i in 0..<help0Label.count {
            playerTableView[i].reloadData()
            redPlayer1Button[i].setTitleColor(self.view.tintColor, for: .normal)
            redPlayer2Button[i].setTitleColor(self.view.tintColor, for: .normal)
            bluePlayer1Button[i].setTitleColor(self.view.tintColor, for: .normal)
            bluePlayer2Button[i].setTitleColor(self.view.tintColor, for: .normal)
        }
        
        playersSegmentedControl[0].accessibilityIdentifier = "NumberOfPlayers"
        playersSegmentedControl[1].accessibilityIdentifier = "NumberOfPlayersP"
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        UserDefaults.standard.set(UIDevice.current.orientation.isLandscape, forKey: "isLandscape")
        
        if tabBarController?.selectedIndex == SCOREBOARD_TAB_INDEX {
            gameViewPortrait.isHidden = UIDevice.current.orientation.isLandscape
            loginViewPortrait.isHidden = UIDevice.current.orientation.isLandscape
            
            if newPlayerTextField[0].isEditing {
                newPlayerTextField[0].resignFirstResponder()
                newPlayerTextField[1].becomeFirstResponder()
            } else if newPlayerTextField[1].isEditing {
                newPlayerTextField[1].resignFirstResponder()
                newPlayerTextField[0].becomeFirstResponder()
            }
            
            if helpState != 0 {
                helpView.isHidden = !UIDevice.current.orientation.isLandscape
                helpViewPortrait.isHidden = UIDevice.current.orientation.isLandscape
            }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        // firebase
        
        // let db = Firestore.firestore()
        
        // set landscape/portrait
        UserDefaults.standard.set(UIApplication.shared.statusBarOrientation.isLandscape, forKey: "isLandscape")
        
        // coreDataDeleteAll(entity: "Matches")
        
        if isLeagueActive() {
            
            players.removeAll()
            
            for i in 0..<help0Label.count {
                activityIndicator[i].startAnimating()
            }
            view.isUserInteractionEnabled = false
            let tabBarControllerItems = self.tabBarController?.tabBar.items

            if let tabArray = tabBarControllerItems {
                for item in tabArray {
                    item.isEnabled = false
                }
            }
            CornholeFirestore.pullLeagues(ids: [UserDefaults.getActiveLeagueID()]) { (leagues, error) in
                self.view.isUserInteractionEnabled = true
                if let tabArray = tabBarControllerItems {
                    for item in tabArray {
                        item.isEnabled = true
                    }
                }
                for i in 0..<self.help0Label.count {
                    self.activityIndicator[i].stopAnimating()
                }
                if error != nil {
                    self.present(createBasicAlert(title: "Error", message: "Unable to pull league \(UserDefaults.getActiveLeagueID())"), animated: true, completion: nil)
                } else if leagues!.count == 0 {
                    self.present(createBasicAlert(title: "Error", message: "Unable to pull league \(UserDefaults.getActiveLeagueID()), it may have been deleted. If you think this is a mistake, note down the ID and try to rejoin."), animated: true, completion: nil)
                    UserDefaults.removeLeagueID(id: UserDefaults.getActiveLeagueID())
                    CornholeFirestore.setLeagues(user: Auth.auth().currentUser!)
                    UserDefaults.setActiveLeagueID(id: CornholeFirestore.TEST_LEAGUE_ID)
                } else {
                    if let league = leagues?[0] {
                        self.league = league
                        self.players = league.players
                        self.players = self.players.sorted()
                        for i in 0..<self.help0Label.count {
                            self.playerTableView[i].reloadData()
                            self.selectPlayersLabel[i].text = league.name
                        }
                    }
                }
            }
        }
        
        let appearance = UITabBarItem.appearance()
        let attributes = [NSAttributedString.Key.font: UIFont(name: systemFont, size: bigDevice() ? 17 : 12)]
        appearance.setTitleTextAttributes(attributes as Any as? [NSAttributedString.Key : Any], for: .normal)
        
        var segmentFont = UIFont(name: systemFont, size: 14)
        
        // adjust for size classes/small devices
        
        // size classes
        if bigDevice() { // big device
            
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
                
                selectPlayersLabel[i].font = UIFont(name: systemFont, size: 60)
                teamRedLabel[i].font = UIFont(name: systemFont, size: 30)
                redPlayer1Label[i].font = UIFont(name: systemFont, size: 30)
                redPlayer2Label[i].font = UIFont(name: systemFont, size: 30)
                teamBlueLabel[i].font = UIFont(name: systemFont, size: 30)
                bluePlayer1Label[i].font = UIFont(name: systemFont, size: 30)
                bluePlayer2Label[i].font = UIFont(name: systemFont, size: 30)
                createNewPlayerLabel[i].font = UIFont(name: systemFont, size: 20)
                selectExistingPlayerLabel[i].font = UIFont(name: systemFont, size: 25)
                
                newPlayerTextField[i].font = UIFont(name: systemFont, size: 20)
                
                helpButton[i].titleLabel?.font = UIFont(name: systemFont, size: 45)
                rulesButton[i].titleLabel?.font = UIFont(name: systemFont, size: 45)
                swapColorsButton[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                changeRedButton[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                changeBlueButton[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                redPlayer1Button[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                redPlayer2Button[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                bluePlayer1Button[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                bluePlayer2Button[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                playButton[i].titleLabel?.font = UIFont(name: systemFont, size: 50)
                trackingStatsButton[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                addNewPlayerButton[i].titleLabel?.font = UIFont(name: systemFont, size: 25)
                
                // constraints
                playersSegmentedControl[i].heightAnchor.constraint(equalToConstant: 50).isActive = true
                playerTableView[i].widthAnchor.constraint(equalToConstant: 400).isActive = true
                
                // game view
                
                totalLabel[i].font = UIFont(name: systemFont, size: 100)
                redTotalScoreLabel[i].font = UIFont(name: systemFont, size: 225)
                blueTotalScoreLabel[i].font = UIFont(name: systemFont, size: 225)
                totalDashLabel[i].font = UIFont(name: systemFont, size: 225)
                roundLabel[i].font = UIFont(name: systemFont, size: 50)
                redRoundScoreLabel[i].font = UIFont(name: systemFont, size: 100)
                blueRoundScoreLabel[i].font = UIFont(name: systemFont, size: 100)
                roundDashLabel[i].font = UIFont(name: systemFont, size: 120)
                redTeamLabel[i].font = UIFont(name: systemFont, size: 25)
                blueTeamLabel[i].font = UIFont(name: systemFont, size: 25)
                redInLabel[i].font = UIFont(name: systemFont, size: 30)
                redOnLabel[i].font = UIFont(name: systemFont, size: 30)
                blueInLabel[i].font = UIFont(name: systemFont, size: 30)
                blueOnLabel[i].font = UIFont(name: systemFont, size: 30)
                
                selectNewPlayersButton[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                roundCompleteButton[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                undoButton[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                resetButton[i].titleLabel?.font = UIFont(name: systemFont, size: 30)
                
                // constraints
                redTeamLabel[i].heightAnchor.constraint(equalToConstant: 250).isActive = true
                blueTeamLabel[i].heightAnchor.constraint(equalToConstant: 250).isActive = true
            }
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
                
                // login view
                
                segmentFont = UIFont(name: systemFont, size: 11)
                
                selectPlayersLabel[i].font = UIFont(name: systemFont, size: 20)
                teamRedLabel[i].font = UIFont(name: systemFont, size: 14)
                redPlayer1Label[i].font = UIFont(name: systemFont, size: 14)
                redPlayer2Label[i].font = UIFont(name: systemFont, size: 14)
                teamBlueLabel[i].font = UIFont(name: systemFont, size: 14)
                bluePlayer1Label[i].font = UIFont(name: systemFont, size: 14)
                bluePlayer2Label[i].font = UIFont(name: systemFont, size: 14)
                createNewPlayerLabel[i].font = UIFont(name: systemFont, size: 12)
                selectExistingPlayerLabel[i].font = UIFont(name: systemFont, size: 14)
                
                totalLabel[i].text = "Score"
                
                newPlayerTextField[i].font = UIFont(name: systemFont, size: 14)
                
                helpButton[i].titleLabel?.font = UIFont(name: systemFont, size: 15)
                rulesButton[i].titleLabel?.font = UIFont(name: systemFont, size: 15)
                swapColorsButton[i].titleLabel?.font = UIFont(name: systemFont, size: 14)
                changeRedButton[i].titleLabel?.font = UIFont(name: systemFont, size: 14)
                changeBlueButton[i].titleLabel?.font = UIFont(name: systemFont, size: 14)
                redPlayer1Button[i].titleLabel?.font = UIFont(name: systemFont, size: 14)
                redPlayer2Button[i].titleLabel?.font = UIFont(name: systemFont, size: 14)
                bluePlayer1Button[i].titleLabel?.font = UIFont(name: systemFont, size: 14)
                bluePlayer2Button[i].titleLabel?.font = UIFont(name: systemFont, size: 14)
                trackingStatsButton[i].titleLabel?.font = UIFont(name: systemFont, size: 15)
                sePlayButton[i].titleLabel?.font = UIFont(name: systemFont, size: 15)
                sePlayButton[i].isHidden = false
                playButton[i].isHidden = true
                addNewPlayerButton[i].titleLabel?.font = UIFont(name: systemFont, size: 14)
                
                // constraints
                playersSegmentedControl[i].heightAnchor.constraint(equalToConstant: 23).isActive = true
                trackingStatsButton[i].widthAnchor.constraint(equalToConstant: 180).isActive = true
                selectExistingPlayerLabel[i].widthAnchor.constraint(equalToConstant: 200).isActive = true
                playerTableView[i].widthAnchor.constraint(equalToConstant: 220).isActive = true
                
                // game view
                
                totalLabel[i].font = UIFont(name: systemFont, size: 40)
                redTotalScoreLabel[i].font = UIFont(name: systemFont, size: 80)
                blueTotalScoreLabel[i].font = UIFont(name: systemFont, size: 80)
                totalDashLabel[i].font = UIFont(name: systemFont, size: 80)
                redTeamLabel[i].font = UIFont(name: systemFont, size: 14)
                blueTeamLabel[i].font = UIFont(name: systemFont, size: 14)
                redInLabel[i].font = UIFont(name: systemFont, size: 14)
                redOnLabel[i].font = UIFont(name: systemFont, size: 14)
                blueInLabel[i].font = UIFont(name: systemFont, size: 14)
                blueOnLabel[i].font = UIFont(name: systemFont, size: 14)
                seTotalDashLabel[i].font = UIFont(name: systemFont, size: 100)
                
                seTotalDashLabel[i].isHidden = false
                totalDashLabel[i].isHidden = true
                redRoundScoreLabel[i].isHidden = true
                blueRoundScoreLabel[i].isHidden = true
                roundDashLabel[i].isHidden = true
                roundLabel[i].isHidden = true
                
                selectNewPlayersButton[i].titleLabel?.font = UIFont(name: systemFont, size: 12.5)
                roundCompleteButton[i].titleLabel?.font = UIFont(name: systemFont, size: 12.5)
                undoButton[i].titleLabel?.font = UIFont(name: systemFont, size: 12.5)
                resetButton[i].titleLabel?.font = UIFont(name: systemFont, size: 11)
                
                // constraints
                redTeamLabel[i].heightAnchor.constraint(equalToConstant: 50).isActive = true
                blueTeamLabel[i].heightAnchor.constraint(equalToConstant: 50).isActive = true
            }
            
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
                createNewPlayerLabel[i].font = UIFont(name: systemFont, size: 12)
                selectExistingPlayerLabel[i].font = UIFont(name: systemFont, size: 17)
                
                newPlayerTextField[i].font = UIFont(name: systemFont, size: 14)
                
                helpButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                rulesButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                swapColorsButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                changeRedButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                changeBlueButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                redPlayer1Button[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                redPlayer2Button[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                bluePlayer1Button[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                bluePlayer2Button[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                playButton[i].titleLabel?.font = UIFont(name: systemFont, size: 20)
                trackingStatsButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                addNewPlayerButton[i].titleLabel?.font = UIFont(name: systemFont, size: 14)
                
                playersSegmentedControl[i].heightAnchor.constraint(equalToConstant: 28).isActive = true
                playerTableView[i].widthAnchor.constraint(equalToConstant: 270).isActive = true
                redTeamLabel[i].heightAnchor.constraint(equalToConstant: 150).isActive = true
                blueTeamLabel[i].heightAnchor.constraint(equalToConstant: 150).isActive = true
                
                // game view
                
                totalLabel[i].font = UIFont(name: systemFont, size: 40)
                redTotalScoreLabel[0].font = UIFont(name: systemFont, size: 150)
                redTotalScoreLabel[1].font = UIFont(name: systemFont, size: 100)
                blueTotalScoreLabel[0].font = UIFont(name: systemFont, size: 150)
                blueTotalScoreLabel[1].font = UIFont(name: systemFont, size: 100)
                totalDashLabel[0].font = UIFont(name: systemFont, size: 150)
                totalDashLabel[1].font = UIFont(name: systemFont, size: 100)
                roundLabel[i].font = UIFont(name: systemFont, size: 25)
                redRoundScoreLabel[i].font = UIFont(name: systemFont, size: 60)
                blueRoundScoreLabel[i].font = UIFont(name: systemFont, size: 60)
                roundDashLabel[i].font = UIFont(name: systemFont, size: 60)
                redTeamLabel[i].font = UIFont(name: systemFont, size: 17)
                blueTeamLabel[i].font = UIFont(name: systemFont, size: 17)
                redInLabel[i].font = UIFont(name: systemFont, size: 17)
                redOnLabel[i].font = UIFont(name: systemFont, size: 17)
                blueInLabel[i].font = UIFont(name: systemFont, size: 17)
                blueOnLabel[i].font = UIFont(name: systemFont, size: 17)
                
                selectNewPlayersButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                roundCompleteButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                undoButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
                resetButton[i].titleLabel?.font = UIFont(name: systemFont, size: 17)
            }
        }
        
        // set backgrounds

        for i in 0..<help0Label.count {
            
            playersSegmentedControl[i].setTitleTextAttributes([NSAttributedString.Key.font: segmentFont!], for: .normal)
            
            gameBackgroundImageView[i].image = backgroundImage
            loginBackgroundImageView[i].image = backgroundImage
            
            if firstLaunch() {
                help(helpButton[i])
            } else {
                if first30Launch() && i == 0 {
                    alert30 = createBasicAlert(title: "New in 3.0: Leagues!", message: "Leagues let you and your friends play and view matches from different devices. For more information, log in at the Settings tab and click \"Edit Leagues\"\n\nNote: Leagues require an internet connection to use.")
                }
            }
            
            newPlayerTextField[i].delegate = self
            newPlayerTextField[i].autocorrectionType = .no
            newPlayerTextField[i].backgroundColor = .clear
            newPlayerTextField[i].layer.borderColor = UIColor.black.cgColor
            
            playerTableView[i].backgroundColor = .clear
            
            selectPlayersLabel[i].adjustsFontSizeToFitWidth = true
            selectPlayersLabel[i].baselineAdjustment = .alignCenters
            selectExistingPlayerLabel[i].adjustsFontSizeToFitWidth = true
            selectExistingPlayerLabel[i].baselineAdjustment = .alignCenters
            redPlayer1Label[i].adjustsFontSizeToFitWidth = true
            redPlayer1Label[i].baselineAdjustment = .alignCenters
            redPlayer1Button[i].contentHorizontalAlignment = .right
            redPlayer2Label[i].adjustsFontSizeToFitWidth = true
            redPlayer2Label[i].baselineAdjustment = .alignCenters
            redPlayer2Button[i].contentHorizontalAlignment = .right
            bluePlayer1Label[i].adjustsFontSizeToFitWidth = true
            bluePlayer1Label[i].baselineAdjustment = .alignCenters
            bluePlayer1Button[i].contentHorizontalAlignment = .right
            bluePlayer2Label[i].adjustsFontSizeToFitWidth = true
            bluePlayer2Label[i].baselineAdjustment = .alignCenters
            bluePlayer2Button[i].contentHorizontalAlignment = .right
        }
 
        helpView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        helpViewPortrait.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let alert = alert30 {
            self.present(alert, animated: true, completion: nil)
            alert30 = nil
        }
        
        for i in 0..<help0Label.count {
            if !isLeagueActive() {
                selectPlayersLabel[i].text = "Select Players"
            } else {
                if let league = UserDefaults.getActiveLeague() {
                    selectPlayersLabel[i].text = league.name
                } else {
                    selectPlayersLabel[i].text = "Select Players"
                }
            }
        }
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
            
            if !isLeagueActive() { // can delete
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
                    
                    for i in 0..<help0Label.count {
                        playerTableView[i].deleteRows(at: [indexPath], with: .fade)
                    }
                } catch {
                    let saveError = error as NSError
                    print(saveError)
                }
            } else { // can't delete
                let alert = UIAlertController(title: "Can't delete", message: "For leagues, delete players from the Leagues menu in Settings", preferredStyle: UIAlertController.Style.alert)
                
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                    self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // check if name already taken
    @IBAction func textFieldEditingChanged(_ sender: Any) {
        if (sender as AnyObject).tag == 0 { // landscape
            newPlayerTextField[1].text = newPlayerTextField[0].text
        } else {
            newPlayerTextField[0].text = newPlayerTextField[1].text
        }
        
        if players.contains(newPlayerTextField[0].text!) {
            for i in 0..<help0Label.count {
                newPlayerTextField[i].backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
            }
        } else {
            for i in 0..<help0Label.count {
                newPlayerTextField[i].backgroundColor = .clear
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.tag == 0 { // landscape
            if !players.contains(newPlayerTextField[0].text!) {
                textField.resignFirstResponder()
            }
            addNewPlayer(addNewPlayerButton[0])
        } else {
            if !players.contains(newPlayerTextField[1].text!) {
                textField.resignFirstResponder()
            }
            addNewPlayer(addNewPlayerButton[0])
        }
        
        return true
    }
    
    // add new player with button
    @IBAction func addNewPlayer(_ sender: Any) {
        
        // get name
        
        var newName = ""
        
        if (sender as AnyObject).tag == 0 { // landscape
            newName = newPlayerTextField[0].text ?? ""
        } else {
            newName = newPlayerTextField[1].text ?? ""
        }
        
        // make sure name isn't taken
        
        if !players.contains(newName) {
        
            // resign keyboard
            view.endEditing(true)
            
            // save player
            if newName != "" && !players.contains(newName) {
                players.append(newName)
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                let context = appDelegate.persistentContainer.viewContext
                
                let newUser = NSEntityDescription.insertNewObject(forEntityName: "Players", into: context)
                newUser.setValue(newName, forKey: "name")
                
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
                    redPlayer1Label[i].text = newName
                    redPlayer1Button[i].setTitleColor(self.view.tintColor, for: .normal)
                    break
                    
                case 2:
                    redPlayer2Label[i].text = newName
                    redPlayer2Button[i].setTitleColor(self.view.tintColor, for: .normal)
                    break
                    
                case 3:
                    bluePlayer1Label[i].text = newName
                    bluePlayer1Button[i].setTitleColor(self.view.tintColor, for: .normal)
                    break
                    
                case 4:
                    bluePlayer2Label[i].text = newName
                    bluePlayer2Button[i].setTitleColor(self.view.tintColor, for: .normal)
                    break
                    
                default:
                    break
                    
                }
            }
            
            for i in 0..<help0Label.count {
                playerTableView[i].reloadData()
                newPlayerTextField[i].text = ""
            }
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
        
        let tmp = redColor
        redColor = blueColor
        blueColor = tmp
        
        setColors()
    }
    
    @IBAction func changeColor(_ sender: UIButton) {
        teamColorToSet = sender.tag
        performSegue(withIdentifier: "changeColorSegue", sender: nil)
    }
    
    var teamColorToSet: Int = 0 // 0 or 1
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // select color segue
        let controller = segue.destination as! SelectColorViewController
        controller.delegate = self
    }
    
    func didSelectColorVC(controller: SelectColorViewController) {
        if teamColorToSet == 0 {
            redColor = controller.color
        } else {
            blueColor = controller.color
        }
        setColors()
    }
    
    func setColors() {
        for i in 0..<help0Label.count {
            
            teamRedLabel[i].textColor = redColor
            let red = COLORS[redColor] != nil ? COLORS[redColor]! : "1"
            teamRedLabel[i].text = "Team \(red)"
            redPlayer1Label[i].textColor = redColor
            redPlayer2Label[i].textColor = redColor
            
            teamBlueLabel[i].textColor = blueColor
            let blue = COLORS[blueColor] != nil ? COLORS[blueColor]! : "2"
            teamBlueLabel[i].text = "Team \(blue)"
            bluePlayer1Label[i].textColor = blueColor
            bluePlayer2Label[i].textColor = blueColor
        }
    }
    
    // open select player dialog
    @IBAction func selectPlayer(_ sender: UIButton) {
        showSelectPlayerMenu(show: true)
        
        buttonSelect = sender.tag
        
        let selectedColor: UIColor = UIColor.gray
        
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
        helpView.isHidden = !UIDevice.current.orientation.isLandscape
        helpViewPortrait.isHidden = UIDevice.current.orientation.isLandscape
        
        helpView.layer.mask = nil
        helpViewPortrait.layer.mask = nil
        
        for i in 0..<help0Label.count {
            help0Label[i].isHidden = false
            help0Label[i].text = "Welcome to Cornhole!\n\nTap to go through instructions"
        }
    }
    
    // show menu
    func showSelectPlayerMenu(show: Bool) {
        for i in 0..<help0Label.count {
            // only allow new player creation if league is not active
            if !isLeagueActive() {
                createNewPlayerLabel[i].isHidden = !show
                newPlayerTextField[i].isHidden = !show
                addNewPlayerButton[i].isHidden = !show
            } else {
                createNewPlayerLabel[i].isHidden = true
                newPlayerTextField[i].isHidden = true
                addNewPlayerButton[i].isHidden = true
            }
            selectExistingPlayerLabel[i].isHidden = !show
            playerTableView[i].isHidden = !show
        }
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
        
        if helpView.isHidden == true && helpViewPortrait.isHidden == true {
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
            createHole(inView: helpView, aroundView: newPlayerTextField[0])
            createHole(inView: helpViewPortrait, aroundView: newPlayerTextField[1])
            
            showSelectPlayerMenu(show: true)
            
            for i in 0..<help0Label.count {
                help2Label[i].isHidden = true
                help3Label[i].isHidden = false
            }
            helpState += 1
        break
            
        case 4:
            createHole(inView: helpView, aroundView: playerTableView[0])
            createHole(inView: helpViewPortrait, aroundView: playerTableView[1])
            
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
            createHoleIPad(inView: helpViewPortrait, aroundView: redInStepper[1])
            
            loginView.isHidden = true
            
            for i in 0..<help0Label.count {
                help6Label[i].isHidden = true
                help7Label[i].isHidden = false
            }
            helpState += 1
        break
            
        case 8:
            createHoleIPad(inView: helpView, aroundView: roundCompleteButton[0])
            createHoleIPad(inView: helpViewPortrait, aroundView: roundCompleteButton[1])
            
            for i in 0..<help0Label.count {
                help7Label[i].isHidden = true
                help8Label[i].isHidden = false
                help8Label[i].text = "Click Round Complete after all bags for the round have been thrown\n"
            }
            helpState += 1
        break
            
        case 9:
            createHoleIPad(inView: helpView, aroundView: resetButton[0])
            createHoleIPad(inView: helpViewPortrait, aroundView: resetButton[1])
            
            for i in 0..<help0Label.count {
                help8Label[i].isHidden = true
                help9Label[i].isHidden = false
                help9Label[i].text = "Click Reset/Restart to restart the game with the same players\n"
            }
            helpState += 1
        break
            
        case 10:
            createHoleIPad(inView: helpView, aroundView: selectNewPlayersButton[0])
            createHoleIPad(inView: helpViewPortrait, aroundView: selectNewPlayersButton[1])
            
            for i in 0..<help0Label.count {
                help9Label[i].isHidden = true
                help10Label[i].isHidden = false
                help10Label[i].text = "Click Select New Players to restart the game with different players\n"
            }
            helpState += 1
        break
            
        case 11:
            createHoleIPad(inView: helpView, aroundView: redTeamLabel[0])
            createHoleIPad(inView: helpViewPortrait, aroundView: redTeamLabel[1])
            
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
            helpViewPortrait.isHidden = true
            helpState = 0
            if first30Launch() {
                self.present(createBasicAlert(title: "New in 3.0: Leagues!", message: "Leagues let you and your friends play and view matches from different devices. For more information, log in at the Settings tab and click \"Edit Leagues\"\n\nNote: Leagues require an internet connection to use."), animated: true, completion: nil)
            }
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
    @IBOutlet var totalLabel: [UILabel]!
    @IBOutlet var redTotalScoreLabel: [UILabel]!
    @IBOutlet var totalDashLabel: [UILabel]!
    @IBOutlet var blueTotalScoreLabel: [UILabel]!
    @IBOutlet var roundLabel: [UILabel]!
    @IBOutlet var redRoundScoreLabel: [UILabel]!
    @IBOutlet var roundDashLabel: [UILabel]!
    @IBOutlet var blueRoundScoreLabel: [UILabel]!
    @IBOutlet var redInLabel: [UILabel]!
    @IBOutlet var redInStepper: [UIStepper]!
    @IBOutlet var redOnLabel: [UILabel]!
    @IBOutlet var redOnStepper: [UIStepper]!
    @IBOutlet var blueInLabel: [UILabel]!
    @IBOutlet var blueInStepper: [UIStepper]!
    @IBOutlet var blueOnLabel: [UILabel]!
    @IBOutlet var blueOnStepper: [UIStepper]!
    @IBOutlet var selectNewPlayersButton: [UIButton]!
    @IBOutlet var roundCompleteButton: [UIButton]!
    @IBOutlet var undoButton: [UIButton]!
    @IBOutlet var resetButton: [UIButton]!
    @IBOutlet var seTotalDashLabel: [UILabel]!
    @IBOutlet weak var stepperStackView: UIStackView!
    
    // stepper clicked
    @IBAction func stepperChanged(_ sender: UIStepper) {
        
        switch(sender.tag) {
        case 0: // red in
            for i in 0..<help0Label.count {
                redInStepper[i].value = sender.value
            }
            break
        case 1:
            for i in 0..<help0Label.count {
                redOnStepper[i].value = sender.value
            }
            break
        case 2:
            for i in 0..<help0Label.count {
                blueInStepper[i].value = sender.value
            }
            break
        case 3:
            for i in 0..<help0Label.count {
                blueOnStepper[i].value = sender.value
            }
            break
        default:
            break
        }
        
        // calculate round scores
        redRoundScore = Int(redInStepper[0].value * 3 + redOnStepper[0].value)
        blueRoundScore = Int(blueInStepper[0].value * 3 + blueOnStepper[0].value)
        
        for i in 0..<help0Label.count {
            redRoundScoreLabel[i].text = "\(redRoundScore)"
            blueRoundScoreLabel[i].text = "\(blueRoundScore)"
            
            // update labels
            redInLabel[i].text = "In: \(Int(redInStepper[0].value))"
            redOnLabel[i].text = "On: \(Int(redOnStepper[0].value))"
            blueInLabel[i].text = "In: \(Int(blueInStepper[0].value))"
            blueOnLabel[i].text = "On: \(Int(blueOnStepper[0].value))"
        }
        
        // update steppers to not exceed bag count
        let redThrown = Int(redInStepper[0].value + redOnStepper[0].value)
        let blueThrown = Int(blueInStepper[0].value + blueOnStepper[0].value)
        
        for i in 0..<help0Label.count {
            redInStepper[i].maximumValue = Double(maxBags - redThrown + Int(redInStepper[0].value))
            redOnStepper[i].maximumValue = Double(maxBags - redThrown + Int(redOnStepper[0].value))
            blueInStepper[i].maximumValue = Double(maxBags - blueThrown + Int(blueInStepper[0].value))
            blueOnStepper[i].maximumValue = Double(maxBags - blueThrown + Int(blueOnStepper[0].value))
        }
    }
    
    // round done
    @IBAction func roundComplete(_ sender: UIButton) {
        
        // remember throwers
        lastFirstThrowerColor = firstThrowerColor
        
        // add round to rounds array
        let redIn = Int(redInStepper[0].value)
        let redOn = Int(redOnStepper[0].value)
        let redOff = maxBags - redIn - redOn
        let blueIn = Int(blueInStepper[0].value)
        let blueOn = Int(blueOnStepper[0].value)
        let blueOff = maxBags - blueIn - blueOn
        
        rounds.append(Round(red: Board(bagsIn: redIn, bagsOn: redOn, bagsOff: redOff), blue: Board(bagsIn: blueIn, bagsOn: blueOn, bagsOff: blueOff), redPlayer: getCurrentPlayers()[0], bluePlayer: getCurrentPlayers()[1]))
        
        // prep for next undo
        lastRedScore = redTotalScore
        lastBlueScore = blueTotalScore
        
        // update total score
        switch gameSettings.gameType {
        case .standard:
            if redRoundScore > blueRoundScore {
                redTotalScore += redRoundScore - blueRoundScore
            } else {
                blueTotalScore += blueRoundScore - redRoundScore
            }
        case .bust:
            if redRoundScore > blueRoundScore {
                redTotalScore += redRoundScore - blueRoundScore
                if redTotalScore > gameSettings.winningScore {
                    redTotalScore = gameSettings.bustScore
                }
            } else {
                blueTotalScore += blueRoundScore - redRoundScore
                if blueTotalScore > gameSettings.winningScore {
                    blueTotalScore = gameSettings.bustScore
                }
            }
        case .rounds:
            if redRoundScore > blueRoundScore {
                redTotalScore += redRoundScore - blueRoundScore
            } else {
                blueTotalScore += blueRoundScore - redRoundScore
            }
        }
        
        for i in 0..<help0Label.count {
            redTotalScoreLabel[i].text = "\(redTotalScore)"
            blueTotalScoreLabel[i].text = "\(blueTotalScore)"
            
            // reset round score
            redRoundScore = 0
            blueRoundScore = 0
            
            redRoundScoreLabel[i].text = "\(redRoundScore)"
            blueRoundScoreLabel[i].text = "\(blueRoundScore)"
        }
        
        // reset steppers
        resetSteppers()
        
        // update first tosser
        round += 1
        if gameSettings.gameType == .rounds {
            for i in 0..<help0Label.count {
                if round <= gameSettings.roundLimit {
                    roundLabel[i].text = "Round \(round)/\(gameSettings.roundLimit)"
                }
            }
        }
        
        // change first toss display
        printFirstToss(undoing: false)
        
        for i in 0..<help0Label.count {
            // show undo button
            undoButton[i].isHidden = false
        }
        
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
            
            if timesPlayed >= 5 && currentDate > fourthOfJulyDate && !hasAskedForReview {
                if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                }
                hasAskedForReview = true
            }
            
            defaults.set(hasAskedForReview, forKey: "hasAskedForReview")
            
            // everything else
            
            for i in 0..<help0Label.count {
                resetButton[i].setTitle("Restart", for: .normal)
            }
            
            // determine winner
            switch gameSettings.gameType {
            case .standard:
                if redTotalScore >= gameSettings.winningScore {
                    for i in 0..<help0Label.count {
                        let team = COLORS[redColor] != nil ? COLORS[redColor]! : "Team 1"
                        roundCompleteButton[i].setTitle("\(team) Wins!", for: .normal)
                        roundCompleteButton[i].setTitleColor(redColor, for: .normal)
                    }
                } else {
                    for i in 0..<help0Label.count {
                        let team = COLORS[blueColor] != nil ? COLORS[blueColor]! : "Team 2"
                        roundCompleteButton[i].setTitle("\(team) Wins!", for: .normal)
                        roundCompleteButton[i].setTitleColor(blueColor, for: .normal)
                    }
                }
            case .bust:
                if redTotalScore >= gameSettings.winningScore {
                    for i in 0..<help0Label.count {
                        let team = COLORS[redColor] != nil ? COLORS[redColor]! : "Team 1"
                        roundCompleteButton[i].setTitle("\(team) Wins!", for: .normal)
                        roundCompleteButton[i].setTitleColor(redColor, for: .normal)
                    }
                } else if blueTotalScore >= gameSettings.winningScore {
                    for i in 0..<help0Label.count {
                        let team = COLORS[blueColor] != nil ? COLORS[blueColor]! : "Team 2"
                        roundCompleteButton[i].setTitle("\(team) Wins!", for: .normal)
                        roundCompleteButton[i].setTitleColor(blueColor, for: .normal)
                    }
                }
            case .rounds:
                if redTotalScore > blueTotalScore {
                    for i in 0..<help0Label.count {
                        let team = COLORS[redColor] != nil ? COLORS[redColor]! : "Team 1"
                        roundCompleteButton[i].setTitle("\(team) Wins!", for: .normal)
                        roundCompleteButton[i].setTitleColor(redColor, for: .normal)
                    }
                } else if blueTotalScore > redTotalScore {
                    for i in 0..<help0Label.count {
                        let team = COLORS[blueColor] != nil ? COLORS[blueColor]! : "Team 2"
                        roundCompleteButton[i].setTitle("\(team) Wins!", for: .normal)
                        roundCompleteButton[i].setTitleColor(blueColor, for: .normal)
                    }
                } else { // tie, playing round limited
                    for i in 0..<help0Label.count {
                        roundCompleteButton[i].setTitle("Tie Game", for: .normal)
                        roundCompleteButton[i].setTitleColor(self.view.tintColor, for: .normal)
                    }
                }
            }
            
            for i in 0..<help0Label.count {
                // disable features
                redInStepper[i].isEnabled = false
                redOnStepper[i].isEnabled = false
                blueInStepper[i].isEnabled = false
                blueOnStepper[i].isEnabled = false
                roundCompleteButton[i].isEnabled = false
                undoButton[i].isHidden = true
            }
            
            // save match if tracking stats
            if trackingStats {
                // create match object
                var lastMatch: Match?
                
                // manage id
                Match.universalID = getNewID(matches: getMatchesFromCoreData())
            
                if oneVOne {
                    lastMatch = Match(redPlayers: [redPlayer1], bluePlayers: [bluePlayer1], rounds: rounds, gameSettings: gameSettings)
                } else {
                    lastMatch = Match(redPlayers: [redPlayer1, redPlayer2], bluePlayers: [bluePlayer1, bluePlayer2], rounds: rounds, gameSettings: gameSettings)
                }
                
                lastMatch?.startDate = startDate!
                lastMatch?.endDate = Date()
                
                if isLeagueActive() {
                    // generate id for league match
                    if lastMatch != nil {
                        lastMatch!.id = -1
                        lastMatch!.redColor = redColor
                        lastMatch!.blueColor = blueColor
                        CornholeFirestore.addMatchToLeague(leagueID: UserDefaults.getActiveLeagueID(), match: lastMatch!)
                    }
                } else {
                    
                    // save match data core data
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                
                    let newUser = NSEntityDescription.insertNewObject(forEntityName: "Matches", into: context)
                    
                    let allPlayers: [String] = (lastMatch?.redPlayers)! + (lastMatch?.bluePlayers)!
                    newUser.setValue(allPlayers, forKey: "playerNamesArray")
                
                    let roundPlayers = lastMatch?.getRoundPlayers()
                    let roundData = lastMatch?.getRoundData()
                    
                    newUser.setValue(roundPlayers, forKey: "roundPlayersArray")
                    newUser.setValue(roundData, forKey: "roundDataArray")
                    newUser.setValue(lastMatch?.id, forKey: "id")
                    newUser.setValue(lastMatch?.startDate, forKey: "startDate")
                    newUser.setValue(lastMatch?.endDate, forKey: "endDate")
                    newUser.setValue(redColor, forKey: "redColor")
                    newUser.setValue(blueColor, forKey: "blueColor")
                    newUser.setValue(gameSettings.gameType.rawValue, forKey: "gameType")
                    newUser.setValue(gameSettings.winningScore, forKey: "winningScore")
                    newUser.setValue(gameSettings.bustScore, forKey: "bustScore")
                    newUser.setValue(gameSettings.roundLimit, forKey: "roundLimit")
                    
                    do {
                        try context.save()
                        print("Saved")
                    } catch {
                        print("Error")
                    }
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
        
        for i in 0..<help0Label.count {
            redTotalScoreLabel[i].text = "\(redTotalScore)"
            blueTotalScoreLabel[i].text = "\(blueTotalScore)"
            undoButton[i].isHidden = true
        }
        
        // backup round
        round -= 1
        rounds.removeLast()
        printFirstToss(undoing: true)
    }
    
    
    @IBAction func resetAlert(_ sender: UIButton) {
        
        if !matchComplete() {
            // make sure
            let alert = UIAlertController(title: "Are you sure?", message: "This will delete all data from this game", preferredStyle: UIAlertController.Style.alert)
        
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive, handler: {(action) in
                alert.dismiss(animated: true, completion: nil)
                
                if sender.tag == 0 { // select new players
                    self.selectNewPlayers()
                } else if sender.tag == 1 { // reset
                    self.reset()
                }
                
            }))
        
            alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: {(action) in
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
        
        // reset game type
        setGameSettings()
        
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
    
        for i in 0..<help0Label.count {
           
            // round label
            if gameSettings.gameType == .rounds {
                roundLabel[i].text = "Round 1/\(gameSettings.roundLimit)"
            } else {
                roundLabel[i].text = "Round"
            }
            
            redTotalScoreLabel[i].text = "\(redTotalScore)"
            blueTotalScoreLabel[i].text = "\(blueTotalScore)"
            
            redRoundScore = 0
            blueRoundScore = 0
            
            redRoundScoreLabel[i].text = "\(redRoundScore)"
            blueRoundScoreLabel[i].text = "\(blueRoundScore)"
            
            // reenable steppers
            redInStepper[i].isEnabled = true
            redOnStepper[i].isEnabled = true
            blueInStepper[i].isEnabled = true
            blueOnStepper[i].isEnabled = true
            
            // update buttons
            roundCompleteButton[i].setTitle("Round Complete", for: .normal)
            roundCompleteButton[i].setTitleColor(self.view.tintColor, for: .normal)
            roundCompleteButton[i].isEnabled = true
            resetButton[i].setTitle("Reset", for: .normal)
            
            // reset undo
            undoButton[i].isHidden = true
            lastRedScore = 0
            lastBlueScore = 0
        }
    
        resetSteppers()
    }
    
    // set steppers to 0
    func resetSteppers() {
        for i in 0..<help0Label.count {
            redInStepper[i].value = 0
            redOnStepper[i].value = 0
            blueInStepper[i].value = 0
            blueOnStepper[i].value = 0
            
            redInStepper[i].maximumValue = Double(maxBags)
            redOnStepper[i].maximumValue = Double(maxBags)
            blueInStepper[i].maximumValue = Double(maxBags)
            blueOnStepper[i].maximumValue = Double(maxBags)
            
            // update labels
            redInLabel[i].text = "In: \(Int(redInStepper[0].value))"
            redOnLabel[i].text = "On: \(Int(redOnStepper[0].value))"
            blueInLabel[i].text = "In: \(Int(blueInStepper[0].value))"
            blueOnLabel[i].text = "On: \(Int(blueOnStepper[0].value))"
        }
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
        switch gameSettings.gameType {
        case .standard:
            return redTotalScore >= gameSettings.winningScore || blueTotalScore >= gameSettings.winningScore
        case .bust:
            return redTotalScore == gameSettings.winningScore || blueTotalScore == gameSettings.winningScore
        case .rounds:
            return rounds.count >= gameSettings.roundLimit
        }
    }
    
    // remember first tosser of previous round
    var lastFirstThrowerColor = Match.RED
    
    // print tossers
    func printFirstToss(undoing: Bool) {
        
        var firstThrowWinners: Bool = UserDefaults.standard.bool(forKey: "firstThrowWinners")
        if isLeagueActive() {
            if let league = UserDefaults.getActiveLeague() {
                firstThrowWinners = league.firstThrowWinners
            }
        }
        
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
        
        for i in 0..<help0Label.count {
            if oneVOne {
                if firstThrowerColor == Match.RED { // red team going
                    redTeamLabel[i].text = "\(redPlayer1) •"
                    blueTeamLabel[i].text = "✕ \(bluePlayer1)"
                } else { // blue team going
                    redTeamLabel[i].text = "\(redPlayer1) ✕"
                    blueTeamLabel[i].text = "• \(bluePlayer1)"
                }
            } else {
                if(firstThrowerColor == Match.RED && firstThrowerPlayer1) { // red player 1
                    redTeamLabel[i].text = "\(redPlayer1) •\n\(redPlayer2)"
                    blueTeamLabel[i].text = "✕ \(bluePlayer1)\n\(bluePlayer2)"
                } else if(firstThrowerColor == Match.RED) { // red player 2
                    redTeamLabel[i].text = "\(redPlayer1)\n\(redPlayer2) •"
                    blueTeamLabel[i].text = "\(bluePlayer1)\n✕ \(bluePlayer2)"
                } else if(firstThrowerPlayer1) { // blue player 1
                    redTeamLabel[i].text = "\(redPlayer1) ✕\n\(redPlayer2)"
                    blueTeamLabel[i].text = "• \(bluePlayer1)\n\(bluePlayer2)"
                } else { // blue player 2
                    redTeamLabel[i].text = "\(redPlayer1)\n\(redPlayer2) ✕"
                    blueTeamLabel[i].text = "\(bluePlayer1)\n• \(bluePlayer2)"
                }
            }
        }
    }
    
    func setGameSettings() {
        let defaults = UserDefaults.standard
        var gT: GameType?
        var wS: Int?
        var bS: Int?
        var rL: Int?
        
        if !isLeagueActive() {
            gT = GameType(rawValue: defaults.integer(forKey: "gameType")) ?? GameType.standard
            wS = defaults.integer(forKey: "winningScore")
            bS = defaults.integer(forKey: "bustScore")
            rL = defaults.integer(forKey: "roundLimit")
            
        } else {
            if let league = UserDefaults.getActiveLeague() {
                gT = league.gameSettings.gameType
                wS = league.gameSettings.winningScore
                bS = league.gameSettings.bustScore
                rL = league.gameSettings.roundLimit
            } else {
                let defaults = UserDefaults.standard
                gT = GameType(rawValue: defaults.integer(forKey: "gameType")) ?? GameType.standard
                wS = defaults.integer(forKey: "winningScore")
                bS = defaults.integer(forKey: "bustScore")
                rL = defaults.integer(forKey: "roundLimit")
            }
        }
        
        switch gT {
        case .standard:
            gameSettings = GameSettings(gameType: .standard, winningScore: wS!)
        case .bust:
            gameSettings = GameSettings(gameType: .bust, winningScore: wS!, bustScore: bS!)
        case .rounds:
            gameSettings = GameSettings(gameType: .rounds, roundLimit: rL!)
        default:
            gameSettings = GameSettings()
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
    
    func first30Launch() -> Bool {
        let alreadyLaunched = UserDefaults.standard.bool(forKey: "alreadyLaunched30")
        if alreadyLaunched {
            return false
        } else {
            UserDefaults.standard.set(true, forKey: "alreadyLaunched30")
            return true
        }
    }
}

