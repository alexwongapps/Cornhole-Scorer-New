//
//  EditLeaguesViewController.swift
//  Cornhole Scorer
//
//  Created by Alex Wong on 10/12/19.
//  Copyright © 2019 Kids Can Code. All rights reserved.
//

import UIKit
import FirebaseAuth
import AVFoundation
import StoreKit
import FirebaseAnalytics

let FREE_LEAGUE_LIMIT = 3

protocol DataToSettingsProtocol {
    func settingsReloadPermissions()
}

class EditLeaguesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVCaptureMetadataOutputObjectsDelegate, ScanViewControllerDelegate {

    var leagues: [League] = []
    
    var delegate: DataToSettingsProtocol? = nil

    var captureSession: AVCaptureSession?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var leaguesTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var joinUnlimitedLeaguesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        // Do any additional setup after loading the view.
        backgroundImageView.image = backgroundImage
        
        // devices
        
        if bigDevice() {
            
            backButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            createButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            joinButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            helpButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            refreshButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
            joinUnlimitedLeaguesButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
        } else if smallDevice() {
            backButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            createButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            joinButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            helpButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            refreshButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            joinUnlimitedLeaguesButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
        } else {
            backButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            createButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            joinButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            helpButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            refreshButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
            joinUnlimitedLeaguesButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
        }
        
        joinUnlimitedLeaguesButton.isHidden = leaguesPaid
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var allIDs = [String]()
        for l in cachedLeagues {
            allIDs.append(l.firebaseID)
        }
        
        print("cached leagues: \(allIDs)")
        print("active league: \(!isLeagueActive() ? "NONE" : UserDefaults.getActiveLeagueID())")
        
        leagues.removeAll()
        
        activityIndicator.startAnimating()
        CornholeFirestore.pullAndCacheLeagues(force: false) { (error, unables) in
            self.activityIndicator.stopAnimating()
            if error != nil {
                self.present(createBasicAlert(title: "Error", message: "Unable to access leagues"), animated: true, completion: nil)
            }
            if let ids = unables {
                if ids.count > 0 {
                    self.present(createBasicAlert(title: "Error", message: deletedLeagueMessage(ids: ids)), animated: true, completion: nil)
                    for id in ids {
                        UserDefaults.removeLeagueID(id: id)
                    }
                    CornholeFirestore.setLeagues(user: Auth.auth().currentUser!)
                }
            }
            for league in cachedLeagues {
                self.leagues.append(league)
            }
            self.leagues = self.leagues.sorted(by: { $0.name < $1.name })
            self.leaguesTableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if first30Launch() {
            firstHelp()
        }
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createLeague(_ sender: Any) {
        if canAddLeague() {
             if let user = Auth.auth().currentUser {
                 let alert = UIAlertController(title: "Create League", message: "Enter the league name", preferredStyle: .alert)
                 alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                 alert.addTextField { (textField) in
                    textField.placeholder = "Name"
                    textField.autocapitalizationType = .words
                 }
                 alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
                     let textField = alert?.textFields![0]
                     if textField?.text != "" {
                        
                         Analytics.logEvent("create_league", parameters: [:])
                        
                         let newLeague = League(name: textField!.text!, owner: user)
                         self.leagues.append(newLeague)
                         self.leaguesTableView.reloadData()
                         CornholeFirestore.createLeague(league: newLeague)
                         UserDefaults.addLeagueID(id: newLeague.firebaseID)
                         UserDefaults.setActiveLeagueID(id: newLeague.firebaseID)
                         CornholeFirestore.setLeagues(user: Auth.auth().currentUser!)
                         self.forcePermissionsReload()
                         self.openDetail(indexPath: IndexPath(row: self.leagues.count - 1, section: 0))
                     }
                 }))
                 self.present(alert, animated: true, completion: nil)
             } else {
                 self.present(createBasicAlert(title: "Not logged in", message: "Must be logged in to create a league"), animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func joinLeague(_ sender: Any) {
        if canAddLeague() {
            let alert = UIAlertController(title: "Add League", message: "Enter the league ID (NOT the league name) or scan its QR code (available in the league settings)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addTextField { (textField) in
                textField.keyboardType = .default
                textField.placeholder = "ID"
            }
            alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
                let trimmed = textField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                self.joinPull(name: trimmed)
            }))
            alert.addAction(UIAlertAction(title: "Scan QR Code", style: .default, handler: { (action) in
                alert.dismiss(animated: true) {
                    self.performSegue(withIdentifier: "qrScanSegue", sender: nil)
                }
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func passID(id: String) {
        _ = navigationController?.popViewController(animated: true)
        joinPull(name: id)
    }
    
    func canAddLeague() -> Bool {
        if leagues.count >= FREE_LEAGUE_LIMIT && !leaguesPaid {
            self.present(createBasicAlert(title: "League limit reached", message: "To follow more than \(FREE_LEAGUE_LIMIT) leagues at a time, click Follow Unlimited Leagues at the bottom of the screen\n\nTo unfollow a league without deleting its data, swipe left on it and press delete"), animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }

    func joinPull(name: String) {
        let alreadyThere = cachedLeagues.contains { $0.firebaseID == name }
        if name != "" {
            if alreadyThere {
                self.present(createBasicAlert(title: "Error", message: "League already added"), animated: true, completion: nil)
            } else {
                self.activityIndicator.startAnimating()
                CornholeFirestore.pullLeagues(ids: [name]) { (leagues, err) in
                    self.activityIndicator.stopAnimating()
                    if let err = err {
                        print("error pulling league: \(err)")
                        self.present(createBasicAlert(title: "Error", message: "Unable to add league. Make sure you entered a valid league ID (20 characters) and check your internet connection."), animated: true, completion: nil)
                    } else if leagues!.count == 0 {
                        self.present(createBasicAlert(title: "Error", message: "Unable to add league. Make sure you entered a valid league ID (20 characters) and check your internet connection."), animated: true, completion: nil)
                    } else if let league = leagues?[0] {
                        if league.name == "" {
                            self.present(createBasicAlert(title: "League not found", message: "A league with this ID was not found"), animated: true, completion: nil)
                        } else {
                            self.leagues.append(league)
                            self.leaguesTableView.reloadData()
                            UserDefaults.addLeagueID(id: league.firebaseID)
                            UserDefaults.setActiveLeagueID(id: league.firebaseID)
                            CornholeFirestore.setLeagues(user: Auth.auth().currentUser!)
                            print(cachedLeagues.count)
                            self.forcePermissionsReload()
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leagues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leagueCell") as! EditLeaguesViewControllerLeagueTableViewCell
        cell.league = leagues[indexPath.row]
        cell.nameLabel.text = cell.league.name
        cell.nameLabel.adjustsFontSizeToFitWidth = true
        cell.nameLabel.baselineAdjustment = .alignCenters
        cell.makeActiveButton.setTitle(UserDefaults.getActiveLeagueID() == cell.league.firebaseID ? "Deactivate" : "Activate", for: .normal)
        cell.backgroundColor = .clear
        
        // fonts
        let fontToUse = UserDefaults.getActiveLeagueID() == cell.league.firebaseID ? systemFontItalic : systemFont
        if bigDevice() {
            cell.nameLabel.font = UIFont(name: fontToUse, size: 30)
            cell.makeActiveButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
        } else if smallDevice() {
            cell.nameLabel.font = UIFont(name: fontToUse, size: 17)
            cell.makeActiveButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
        } else {
            cell.nameLabel.font = UIFont(name: fontToUse, size: 17)
            cell.makeActiveButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let alert = UIAlertController(title: "Are you sure?", message: "This will NOT delete the league or its data, it will just remove it from your followed leagues. If you want to follow this league again later, save its ID", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
                
                if self.leagues[indexPath.row].firebaseID == UserDefaults.getActiveLeagueID() {
                    UserDefaults.setActiveLeagueID(id: CornholeFirestore.TEST_LEAGUE_ID)
                }
                self.leagues.remove(at: indexPath.row)
                self.leaguesTableView.deleteRows(at: [indexPath], with: .fade)
                self.leaguesTableView.reloadData()
                UserDefaults.removeLeagueID(at: indexPath.row)
                CornholeFirestore.setLeagues(user: Auth.auth().currentUser!)
                self.forcePermissionsReload()
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    let helpTitles = ["Create a New League", "Add an Existing League", "Activate/Deactivate Leagues", "View League Info", "Internet"]
    let helpMessages = ["Click the Create button and enter your league name", "Click the Add button, then either:\n\n1. Enter the league ID (20 characters)\n2. Scan the league QR code", "To view a league in the rest of the app, click the Activate button next to its name\n\nTo view local (non-league) matches, deactivate all leagues", "Click the league's row in the table", "Leagues require an internet connection to use"]
    
    @IBAction func help(_ sender: Any) {
        let alert = UIAlertController()
        for i in 0..<helpTitles.count {
            alert.addAction(UIAlertAction(title: accessHelp(index: i)[0], style: .default, handler: { (action) in
                self.multipleHelp(titles: [self.accessHelp(index: i)[0]], messages: [self.accessHelp(index: i)[1]])
            }))
        }
        self.present(alert, animated: true)
        
        // ipad support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = helpButton
        }
    }
    
    func firstHelp() {
        multipleHelp(titles: ["Help"] + helpTitles, messages: ["Click Next to learn how to use leagues!"] + helpMessages)
    }
    
    func multipleHelp(titles: [String], messages: [String]) {
        let alert = UIAlertController(title: titles[0], message: messages[0], preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: titles.count == 1 ? "Done" : "Next", style: .default, handler: { (action) in
            if titles.count == 1 {
                return
            } else {
                self.multipleHelp(titles: titles.suffix(titles.count - 1), messages: messages.suffix(messages.count - 1))
            }
        }))
        self.present(alert, animated: true)
    }
    
    func accessHelp(index: Int) -> [String] {
        return [helpTitles[index], helpMessages[index]]
    }
    
    @IBAction func refresh(_ sender: Any) {
        activityIndicator.startAnimating()
        refreshButton.isHidden = true
        CornholeFirestore.pullAndCacheLeagues(force: true) { (error, unables) in
            self.activityIndicator.stopAnimating()
            self.refreshButton.isHidden = false
            if let ids = unables {
                if ids.count > 0 {
                    self.present(createBasicAlert(title: "Error", message: deletedLeagueMessage(ids: ids)), animated: true, completion: nil)
                    for id in ids {
                        UserDefaults.removeLeagueID(id: id)
                    }
                    CornholeFirestore.setLeagues(user: Auth.auth().currentUser!)
                }
            }
            if error != nil {
                self.present(createBasicAlert(title: "Error", message: "Unable to access leagues"), animated: true, completion: nil)
            } else {
                self.viewWillAppear(true)
                self.forcePermissionsReload()
            }
        }
    }
    
    @IBAction func makeActive(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: leaguesTableView)
        let indexPath = leaguesTableView.indexPathForRow(at: buttonPosition)
        let cell = leaguesTableView.cellForRow(at: indexPath!) as! EditLeaguesViewControllerLeagueTableViewCell
        
        if UserDefaults.getActiveLeagueID() == cell.league.firebaseID { // deactivate
            UserDefaults.setActiveLeagueID(id: CornholeFirestore.TEST_LEAGUE_ID)
        } else { // activate
            UserDefaults.setActiveLeagueID(id: cell.league.firebaseID)
            print(UserDefaults.getActiveLeagueID())
        }
        leaguesTableView.reloadData()
        forcePermissionsReload()
    }
    
    func forcePermissionsReload() {
        if self.delegate != nil {
            self.delegate?.settingsReloadPermissions()
        }
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
            controller.delegate = delegate
        case "qrScanSegue":
            let controller = segue.destination as! QRScanViewController
            controller.delegate = self
        default:
            break
        }
    }
    
    func first30Launch() -> Bool {
        let alreadyLaunched = UserDefaults.standard.bool(forKey: "alreadyLaunched30EL")
        if alreadyLaunched {
            return false
        } else {
            UserDefaults.standard.set(true, forKey: "alreadyLaunched30EL")
            return true
        }
    }
    
    @IBAction func joinUnlimitedLeagues(_ sender: Any) {
        activityIndicator.startAnimating()
        IAPManager.shared.startObserving()
        
        IAPManager.shared.getProducts { (result) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                switch result {
                case .success(let products):
                    var product: SKProduct?
                    for p in products {
                        if p.productIdentifier == IAP_UNLIMITED_LEAGUES {
                            product = p
                        }
                    }
                    if product != nil {
                        self.unlimitedLeaguesAlert(product: product!)
                    } else {
                        self.present(createBasicAlert(title: "Error", message: "Could not access in-app purchase."), animated: true)
                    }
                case .failure(let error):
                    self.present(createBasicAlert(title: "Error", message: error.errorDescription ?? ""), animated: true)
                    IAPManager.shared.stopObserving()
                }
            }
        }
    }
    
    func unlimitedLeaguesAlert(product: SKProduct) {
        guard let price = IAPManager.shared.getPriceFormatted(for: product) else { return }
        
        let alert = UIAlertController(title: "Follow Unlimited Leagues", message: "This one-time purchase for \(price) will allow you to follow unlimited leagues at the same time.\n\nThis does NOT include Cornhole Scorer PRO, which can be purchased in the main Settings tab.\n\nTo restore a previous purchase, click Restore in the main Settings tab.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Buy Now", style: .default, handler: { (action) in
            if !self.purchase(product: product) {
                self.present(createBasicAlert(title: "Error", message: "In-App Purchases are not allowed in this device."), animated: true)
                IAPManager.shared.stopObserving()
            }
        }))
        self.present(alert, animated: true)
    }
    
    func purchase(product: SKProduct) -> Bool {
        if !IAPManager.shared.canMakePayments() {
            return false
        } else {
            activityIndicator.startAnimating()
            IAPManager.shared.buy(product: product) { (result) in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    switch result {
                    case .success(_):
                        print("success")
                        self.present(createBasicAlert(title: "Purchase Complete", message: "You can now follow unlimited leagues."), animated: true)
                        self.joinUnlimitedLeaguesButton.isHidden = true
                    case .failure(let error):
                        self.present(createBasicAlert(title: "Error", message: error.localizedDescription), animated: true)
                    }
                    IAPManager.shared.stopObserving()
                }
            }
        }
     
        return true
    }
}
