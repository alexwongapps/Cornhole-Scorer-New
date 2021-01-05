//
//  StatsViewController.swift
//  Cornhole
//
//  Created by Alex Wong on 7/5/18.
//  Copyright © 2018 Kids Can Code. All rights reserved.
//

import UIKit
import Charts
import FirebaseAnalytics

class StatsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var matches: [Match] = []
    var allPlayers: [String] = []
    var player: String = "" // current player
    
    // date stuff
    let now = Date()
    let dateFormatter = DateFormatter()
    var monthName = ""
    var year = ""
    
    var pickerViewTimes = ["All-Time", "Today", "Last 7 Days", "", ""]
    let ALL_TIME = 0
    let TODAY = 1
    let SEVEN_DAYS = 2
    let MONTH = 3
    let YEAR = 4
    
    @IBOutlet var statsLabel: [UILabel]!
    @IBOutlet var playersPickerView: [UIPickerView]!
    @IBOutlet var timePickerView: [UIPickerView]!
    @IBOutlet var singlesRecordLabel: [UILabel]!
    @IBOutlet var matchRecordLabel: [UILabel]!
    @IBOutlet var doublesRecordLabel: [UILabel]!
    @IBOutlet var roundRecordLabel: [UILabel]!
    @IBOutlet var pointsPerRoundLabel: [UILabel]!
    @IBOutlet var inPerRoundLabel: [UILabel]!
    @IBOutlet var onPerRoundLabel: [UILabel]!
    @IBOutlet var offPerRoundLabel: [UILabel]!
    @IBOutlet var bagLocationLabel: [UILabel]!
    @IBOutlet var boardPieChartView: [PieChartView]! // displays in, on, off
    @IBOutlet var activityIndicator: [UIActivityIndicatorView]!
    @IBOutlet var optionsButton: [UIButton]!
    @IBOutlet var standingsButton: [UIButton]!
    
    // background
    @IBOutlet var backgroundImageView: [UIImageView]!
    @IBOutlet weak var portraitView: UIView!
    
    // board pie chart
    var inDataEntry = PieChartDataEntry(value: 0)
    var onDataEntry = PieChartDataEntry(value: 0)
    var offDataEntry = PieChartDataEntry(value: 0)
    var bagsDataEntries = [PieChartDataEntry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        // Do any additional setup after loading the view.
        
        for i in 0..<matchRecordLabel.count {
            backgroundImageView[i].image = backgroundImage
            statsLabel[i].text = ""
            statsLabel[i].adjustsFontSizeToFitWidth = true
            statsLabel[i].baselineAdjustment = .alignCenters
        }
        
        if bigDevice() {
        
            for i in 0..<matchRecordLabel.count {
                bagLocationLabel[i].font = UIFont(name: systemFont, size: 25)
                statsLabel[i].font = UIFont(name: systemFont, size: 75)
                optionsButton[i].titleLabel?.font = UIFont(name: systemFont, size: 25)
                standingsButton[i].titleLabel?.font = UIFont(name: systemFont, size: 25)
                matchRecordLabel[i].font = UIFont(name: systemFont, size: 25)
                singlesRecordLabel[i].font = UIFont(name: systemFont, size: 25)
                doublesRecordLabel[i].font = UIFont(name: systemFont, size: 25)
                roundRecordLabel[i].font = UIFont(name: systemFont, size: 25)
                pointsPerRoundLabel[i].font = UIFont(name: systemFont, size: 25)
                inPerRoundLabel[i].font = UIFont(name: systemFont, size: 25)
                onPerRoundLabel[i].font = UIFont(name: systemFont, size: 25)
                offPerRoundLabel[i].font = UIFont(name: systemFont, size: 25)
                boardPieChartView[i].widthAnchor.constraint(equalToConstant: 400).isActive = true
            }
            
        } else if smallDevice() {
            
            for i in 0..<matchRecordLabel.count {
                bagLocationLabel[i].font = UIFont(name: systemFont, size: 15)
                statsLabel[i].font = UIFont(name: systemFont, size: 30)
                optionsButton[i].titleLabel?.font = UIFont(name: systemFont, size: 11)
                standingsButton[i].titleLabel?.font = UIFont(name: systemFont, size: 11)
                matchRecordLabel[i].font = UIFont(name: systemFont, size: 11)
                singlesRecordLabel[i].font = UIFont(name: systemFont, size: 11)
                doublesRecordLabel[i].font = UIFont(name: systemFont, size: 11)
                roundRecordLabel[i].font = UIFont(name: systemFont, size: 11)
                pointsPerRoundLabel[i].font = UIFont(name: systemFont, size: 11)
                inPerRoundLabel[i].font = UIFont(name: systemFont, size: 11)
                onPerRoundLabel[i].font = UIFont(name: systemFont, size: 11)
                offPerRoundLabel[i].font = UIFont(name: systemFont, size: 11)
                
                boardPieChartView[i].widthAnchor.constraint(equalToConstant: 180).isActive = true
            }
            
        } else {
            
            for i in 0..<matchRecordLabel.count {
                bagLocationLabel[i].font = UIFont(name: systemFont, size: 15)
                statsLabel[i].font = UIFont(name: systemFont, size: 30)
                optionsButton[i].titleLabel?.font = UIFont(name: systemFont, size: 15)
                standingsButton[i].titleLabel?.font = UIFont(name: systemFont, size: 15)
                matchRecordLabel[i].font = UIFont(name: systemFont, size: 15)
                singlesRecordLabel[i].font = UIFont(name: systemFont, size: 15)
                doublesRecordLabel[i].font = UIFont(name: systemFont, size: 15)
                roundRecordLabel[i].font = UIFont(name: systemFont, size: 15)
                pointsPerRoundLabel[i].font = UIFont(name: systemFont, size: 15)
                inPerRoundLabel[i].font = UIFont(name: systemFont, size: 15)
                onPerRoundLabel[i].font = UIFont(name: systemFont, size: 15)
                offPerRoundLabel[i].font = UIFont(name: systemFont, size: 15)
                boardPieChartView[i].widthAnchor.constraint(equalToConstant: 220).isActive = true
            }
            
        }
        
        // date stuff
        dateFormatter.dateFormat = "LLL"
        monthName = dateFormatter.string(from: now)
        dateFormatter.dateFormat = "yyyy"
        year = dateFormatter.string(from: now)
        
        pickerViewTimes[MONTH] = "\(monthName). \(year)"
        pickerViewTimes[YEAR] = year
        
        activityIndicator[0].accessibilityIdentifier = "StatsActivity"
        activityIndicator[1].accessibilityIdentifier = "StatsActivityP"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // landscape/portrait
        portraitView.isHidden = UserDefaults.standard.bool(forKey: "isLandscape")
        
        for i in 0..<matchRecordLabel.count {
            playersPickerView[i].selectRow(0, inComponent: 0, animated: false)
            timePickerView[i].selectRow(0, inComponent: 0, animated: false)
        }
        
        // core data/firestore
        
        if !isLeagueActive() { // no league
            for i in 0..<matchRecordLabel.count {
                statsLabel[i].text = "Stats"
                standingsButton[i].isHidden = true
            }
            matches = getMatchesFromCoreData()
            loadData()
        } else { // league
            for i in 0..<self.matchRecordLabel.count {
                standingsButton[i].isHidden = false
            }
            if let league = UserDefaults.getActiveLeague() {
                for i in 0..<self.matchRecordLabel.count {
                    self.statsLabel[i].text = league.name
                }
                self.matches = league.matches
                self.loadData()
            }
        }
    }
    
    func loadData() {
        allPlayers = getMatchPlayers(array: matches)
        
        for i in 0..<matchRecordLabel.count {
            playersPickerView[i].reloadAllComponents()
            playersPickerView[i].reloadInputViews()
            
            // chart settings
            boardPieChartView[i].chartDescription?.text = ""
            boardPieChartView[i].drawHoleEnabled = false
            let legend = boardPieChartView[i].legend
            legend.font = UIFont(name: systemFont, size: bigDevice() ? 20 : 12)!
        }
        
        // initialize player
        if allPlayers.count > 0 {
            
            for i in 0..<matchRecordLabel.count {
                playersPickerView[i].isHidden = false
                
                player = allPlayers[playersPickerView[i].selectedRow(inComponent: 0)] // just for load
            }
                
            // set labels
            let m = getMatchResults(p: player, m: matches)
            let s = getSinglesResults(p: player, m: matches)
            let d = getDoublesResults(p: player, m: matches)
            let r = getRoundResults(p: player, m: matches)
            let ppr = getPointsPerRound(p: player, m: matches)
            
            for i in 0..<matchRecordLabel.count {
                matchRecordLabel[i].text = "Match Record: \(Int(m[0]))-\(Int(m[1]))-\(Int(m[2])) (\(m[3])%)"
                singlesRecordLabel[i].text = "Singles Record: \(Int(s[0]))-\(Int(s[1]))-\(Int(s[2])) (\(s[3])%)"
                doublesRecordLabel[i].text = "Doubles Record: \(Int(d[0]))-\(Int(d[1]))-\(Int(d[2])) (\(d[3])%)"
                roundRecordLabel[i].text = "Round Record: \(Int(r[0]))-\(Int(r[1]))-\(Int(r[2])) (\(r[3])%)"
                pointsPerRoundLabel[i].text = "Points (Per 4 Bags): \(ppr)"
            }
            
            // get bag info
            let bagData = getBagData(p: player, m: matches)
            
            let bagsThrown = Double(bagData[0] + bagData[1] + bagData[2])
            for i in 0..<matchRecordLabel.count {
                inPerRoundLabel[i].text = "Bags In (Per 4 Bags): \(round(number: Double(bagData[0]) / bagsThrown * 4, places: 2))"
                onPerRoundLabel[i].text = "Bags On (Per 4 Bags): \(round(number: Double(bagData[1]) / bagsThrown * 4, places: 2))"
                offPerRoundLabel[i].text = "Bags Off (Per 4 Bags): \(round(number: Double(bagData[2]) / bagsThrown * 4, places: 2))"
                
                boardPieChartView[i].isHidden = false
            }
            
            inDataEntry.value = Double(bagData[0])
            onDataEntry.value = Double(bagData[1])
            offDataEntry.value = Double(bagData[2])
            
            inDataEntry.label = "In"
            onDataEntry.label = "On"
            offDataEntry.label = "Off"
            
            bagsDataEntries = [inDataEntry, onDataEntry, offDataEntry]
            updateChartData()
        } else {
            for i in 0..<matchRecordLabel.count {
                playersPickerView[i].isHidden = true
            }
            
            noMatchesDisplay()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        UserDefaults.standard.set(UIDevice.current.orientation.isLandscape, forKey: "isLandscape")
        
        if tabBarController?.selectedIndex == STATS_TAB_INDEX {
            portraitView.isHidden = UIDevice.current.orientation.isLandscape
        }
    }
    
    @IBAction func options(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        if isLeagueActive() {
            alert.addAction(UIAlertAction(title: "Refresh", style: .default, handler: { (action) in
                self.refresh()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Export Data", style: .default, handler: { (action) in
            if proPaid {
                self.exportData()
            } else {
                self.present(createBasicAlert(title: "PRO Feature", message: "To get Cornhole Scorer PRO, go to the Settings tab"), animated: true, completion: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func refresh() {
        for i in 0..<matchRecordLabel.count {
            activityIndicator[i].startAnimating()
            standingsButton[i].isHidden = true
        }
        CornholeFirestore.pullLeagues(ids: [UserDefaults.getActiveLeagueID()]) { (league, error) in
            for i in 0..<self.matchRecordLabel.count {
                self.activityIndicator[i].stopAnimating()
                self.standingsButton[i].isHidden = false
            }
            if error != nil {
                self.present(createBasicAlert(title: "Error", message: "Unable to pull current league"), animated: true, completion: nil)
            } else {
                self.viewWillAppear(true)
            }
        }
    }
    
    // picker view
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return allPlayers.count
        } else {
            return 5 // all-time, today, last 7 days, this month, this year
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font? = UIFont(name: systemFont, size: bigDevice() ? 25 : 17)!
            pickerLabel?.textAlignment = .center
        }
        if pickerView.tag == 0 {
            if allPlayers.count > 0 {
                pickerLabel?.text = allPlayers[row]
            }
        } else { // time picker view
            pickerLabel?.text = pickerViewTimes[row]
        }
        pickerLabel?.textColor = self.view.tintColor
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // set for landscape/portrait
        for i in 0..<matchRecordLabel.count {
            if pickerView.tag == 0 {
                playersPickerView[i].selectRow(row, inComponent: 0, animated: false)
            } else {
                timePickerView[i].selectRow(row, inComponent: 0, animated: false)
            }
        }
        
        var statsMatches = [Match]() // matches to use for stats
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        switch timePickerView[0].selectedRow(inComponent: 0) {
            
        case ALL_TIME:
            statsMatches = matches
        break
            
        case TODAY:
            let dateAtMidnight = calendar.startOfDay(for: now)
            statsMatches = getMatchesAfter(matches: matches, date: dateAtMidnight)
        break
            
        case SEVEN_DAYS:
            var dayComp = DateComponents()
            dayComp.day = -6
            let date = calendar.date(byAdding: dayComp, to: now)
            let dateAtMidnight = calendar.startOfDay(for: date!)
            statsMatches = getMatchesAfter(matches: matches, date: dateAtMidnight)
        break
            
        case MONTH:
            let components = calendar.dateComponents([.year, .month], from: now)
            let startOfMonth = calendar.date(from: components)!
            let dateAtMidnight = calendar.startOfDay(for: startOfMonth)
            statsMatches = getMatchesAfter(matches: matches, date: dateAtMidnight)
        break
            
        case YEAR:
            let year = calendar.component(.year, from: now)
            let firstOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))
            let dateAtMidnight = calendar.startOfDay(for: firstOfYear!)
            statsMatches = getMatchesAfter(matches: matches, date: dateAtMidnight)
        break
            
        default:
        break
            
        }
        
        if pickerView.tag == 0 {
            player = allPlayers[row]
        }
        
        if statsMatches.count > 0 &&
            (getMatchResults(p: player, m: statsMatches)[0] + getMatchResults(p: player, m: statsMatches)[1] + getMatchResults(p: player, m: statsMatches)[2]) > 0 // player has played a match
            {
            // set labels
            let m = getMatchResults(p: player, m: statsMatches)
            let s = getSinglesResults(p: player, m: statsMatches)
            let d = getDoublesResults(p: player, m: statsMatches)
            let r = getRoundResults(p: player, m: statsMatches)
            let ppr = getPointsPerRound(p: player, m: statsMatches)
            
            for i in 0..<matchRecordLabel.count {
                matchRecordLabel[i].text = "Match Record: \(Int(m[0]))-\(Int(m[1]))-\(Int(m[2])) (\(m[3])%)"
                singlesRecordLabel[i].text = "Singles Record: \(Int(s[0]))-\(Int(s[1]))-\(Int(s[2])) (\(s[3])%)"
                doublesRecordLabel[i].text = "Doubles Record: \(Int(d[0]))-\(Int(d[1]))-\(Int(d[2])) (\(d[3])%)"
                roundRecordLabel[i].text = "Round Record: \(Int(r[0]))-\(Int(r[1]))-\(Int(r[2])) (\(r[3])%)"
                pointsPerRoundLabel[i].text = "Points (Per 4 Bags): \(ppr)"
            }
            
            // get bag info
            let bagData = getBagData(p: player, m: statsMatches)
            
            let bagsThrown = Double(bagData[0] + bagData[1] + bagData[2])
            for i in 0..<matchRecordLabel.count {
                inPerRoundLabel[i].text = "Bags In (Per 4 Bags): \(round(number: Double(bagData[0]) / bagsThrown * 4, places: 2))"
                onPerRoundLabel[i].text = "Bags On (Per 4 Bags): \(round(number: Double(bagData[1]) / bagsThrown * 4, places: 2))"
                offPerRoundLabel[i].text = "Bags Off (Per 4 Bags): \(round(number: Double(bagData[2]) / bagsThrown * 4, places: 2))"
            }
        
            inDataEntry.value = Double(bagData[0])
            onDataEntry.value = Double(bagData[1])
            offDataEntry.value = Double(bagData[2])
        
            bagsDataEntries = [inDataEntry, onDataEntry, offDataEntry]
            updateChartData()
                
            for i in 0..<matchRecordLabel.count {
                boardPieChartView[i].isHidden = false
            }
        } else {
            noMatchesDisplay()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return bigDevice() ? 50 : 27
    }

    func updateChartData() {
        let chartDataSet = PieChartDataSet(entries: bagsDataEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 0
        formatter.multiplier = 1.0
        chartData.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        
        let colors = [UIColor(red: 0, green: (100.0 / 255.0), blue: 0, alpha: 1), UIColor(red: (153.0 / 255.0), green: (153.0 / 255.0), blue: 0, alpha: 1), UIColor(red: (139.0 / 255.0), green: 0, blue: 0, alpha: 1)]
        chartDataSet.colors = colors
        
        for i in 0..<matchRecordLabel.count {
            boardPieChartView[i].data = chartData
        }
    }
    
    // export
    
    func exportData() {
        
        var fileName = ""
        var path: URL?
        var csvText = ""
        
        let alert = UIAlertController(title: "Choose data", message: "How would you like your data organized?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "By Match", style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            
            fileName = "MatchData.csv"
            path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            
            csvText = getCSVText(matches: self.matches)
            
            do {
                try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                
                let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
                vc.excludedActivityTypes = [
                    UIActivity.ActivityType.addToReadingList,
                    UIActivity.ActivityType.assignToContact,
                    UIActivity.ActivityType.postToFacebook,
                    UIActivity.ActivityType.postToFlickr,
                    UIActivity.ActivityType.postToTencentWeibo,
                    UIActivity.ActivityType.postToTwitter,
                    UIActivity.ActivityType.postToVimeo,
                    UIActivity.ActivityType.postToWeibo,
                    UIActivity.ActivityType.saveToCameraRoll
                ]
                self.present(vc, animated: true, completion: nil)
                if let popover = vc.popoverPresentationController {
                    if self.portraitView.isHidden {
                        popover.sourceView = self.optionsButton[1]
                    } else {
                        popover.sourceView = self.optionsButton[0]
                    }
                }
                
                Analytics.logEvent("export_data", parameters: [
                    "sort_type": "match" as NSObject
                ])
            } catch {
                print("Failed to create file")
                print("\(error)")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "By Player", style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            
            fileName = "PlayerData.csv"
            path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            csvText.append("Player,Matches Played,Matches Won,Matches Lost,Matches Tied,Singles Played,Singles Won,Singles Lost,Singles Tied,Doubles Played,Doubles Won,Doubles Lost,Doubles Tied,Rounds Played,Rounds Won,Rounds Lost,Rounds Tied,Total Bags Thrown,Total Bags In,Total Bags On,Total Bags Off,Total Points\n")
            
            // get data
            for player in self.allPlayers {
                let m = self.getMatchResults(p: player, m: self.matches)
                let s = self.getSinglesResults(p: player, m: self.matches)
                let d = self.getDoublesResults(p: player, m: self.matches)
                let r = self.getRoundResults(p: player, m: self.matches)
                let b = self.getBagData(p: player, m: self.matches)
                
                csvText.append("\(player),\(Int(m[0] + m[1] + m[2])),\(Int(m[0])),\(Int(m[1])),\(Int(m[2])),\(Int(s[0] + s[1] + s[2])),\(Int(s[0])),\(Int(s[1])),\(Int(s[2])),\(Int(d[0] + d[1] + d[2])),\(Int(d[0])),\(Int(d[1])),\(Int(d[2])),\(Int(r[0] + r[1] + r[2])),\(Int(r[0])),\(Int(r[1])),\(Int(r[2])),\(b[0] + b[1] + b[2]),\(b[0]),\(b[1]),\(b[2]),\(Board(bagsIn: b[0], bagsOn: b[1], bagsOff: b[2]).score)\n")
            }
            
            do {
                try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                
                let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
                vc.excludedActivityTypes = [
                    UIActivity.ActivityType.addToReadingList,
                    UIActivity.ActivityType.assignToContact,
                    UIActivity.ActivityType.postToFacebook,
                    UIActivity.ActivityType.postToFlickr,
                    UIActivity.ActivityType.postToTencentWeibo,
                    UIActivity.ActivityType.postToTwitter,
                    UIActivity.ActivityType.postToVimeo,
                    UIActivity.ActivityType.postToWeibo,
                    UIActivity.ActivityType.saveToCameraRoll
                ]
                self.present(vc, animated: true, completion: nil)
                if let popover = vc.popoverPresentationController {
                    if self.portraitView.isHidden {
                        popover.sourceView = self.optionsButton[1]
                    } else {
                        popover.sourceView = self.optionsButton[0]
                    }
                }
                
                Analytics.logEvent("export_data", parameters: [
                    "sort_type": "player" as NSObject
                ])
            } catch {
                print("Failed to create file")
                print("\(error)")
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // advanced stats (not implemented yet)
    
    func getClutchRating(p: String, m: [Match]) -> Double {
        
        let ppr: Double = getPointsPerRound(p: p, m: m)
        
        var points: [Double] = []
        var meanScores: [Double] = []
        
        // get data
        for match in m {
            for r in 0..<match.rounds.count {
                let round: Round = match.rounds[r]
                
                if round.isInRound(player: p) {
                    
                    // get scores from before round started
                    let redScore: Int = match.getTeamScoreAfterRound(team: Match.RED, round: r)
                    let blueScore: Int = match.getTeamScoreAfterRound(team: Match.BLUE, round: r)
                    
                    // add player's score
                    if round.redPlayer == p {
                        points.append(Double(round.red.score))
                    } else {
                        points.append(Double(round.blue.score))
                    }
                    
                    meanScores.append(Double(redScore + blueScore) / 2)
                }
            }
        }
        
        var ratingSum: Double = 0
        
        // calculate clutch rating
        for i in 0..<points.count {
            ratingSum += (points[i] - ppr) * (meanScores[i] - (Double(WINNING_SCORE) / 2))
        }
        
        return ratingSum / Double(points.count)
    }
    
    // what to do with no matches
    func noMatchesDisplay() {
        for i in 0..<matchRecordLabel.count {
            boardPieChartView[i].isHidden = true
        }
        
        for i in 0..<matchRecordLabel.count {
            matchRecordLabel[i].text = "Match Record: "
            singlesRecordLabel[i].text = "Singles Record: "
            doublesRecordLabel[i].text = "Doubles Record: "
            roundRecordLabel[i].text = "Round Record: "
            pointsPerRoundLabel[i].text = "Points (Per 4 Bags): "
            inPerRoundLabel[i].text = "Bags In (Per 4 Bags): "
            onPerRoundLabel[i].text = "Bags On (Per 4 Bags): "
            offPerRoundLabel[i].text = "Bags Off (Per 4 Bags): "
        }
    }
    
    func getMatchesAfter(matches: [Match], date: Date) -> [Match] {
        var retMatches = [Match]()
        
        for match in matches {
            // if match is after date to compare to
            if date.compare(match.startDate) == ComparisonResult.orderedAscending || date.compare(match.startDate) == ComparisonResult.orderedSame {
                retMatches.append(match) // add it
            }
        }
        
        return retMatches
    }
    
    // data getters
    
    // [won, lost, tied, percent]
    func getSinglesResults(p: String, m: [Match]) -> [Double] {
        var wins = 0
        var losses = 0
        var totalMatches = 0
        
        for match in m {
            if match.isInMatch(player: p) && match.redPlayers.count == 1 {
                if match.getResult(player: p) == Match.WIN {
                    wins += 1
                } else if match.getResult(player: p) == Match.LOSS {
                    losses += 1
                }
                totalMatches += 1
            }
        }
        
        let dW = Double(wins)
        let dL = Double(losses)
        let dT = Double(totalMatches - wins - losses)
        
        var ret = [dW, dL, dT, round(number: ((dW + (0.5 * dT)) / Double(totalMatches)) * 100.0, places: 1)]
        
        if totalMatches == 0 {
            ret[ret.count - 1] = 0
        }
        
        return ret
    }
    
    // [won, lost, tied, percent]
    func getDoublesResults(p: String, m: [Match]) -> [Double] {
        var wins = 0
        var losses = 0
        var totalMatches = 0
        
        for match in m {
            if match.isInMatch(player: p) && match.redPlayers.count == 2 {
                if match.getResult(player: p) == Match.WIN {
                    wins += 1
                } else if match.getResult(player: p) == Match.LOSS {
                    losses += 1
                }
                totalMatches += 1
            }
        }
        
        let dW = Double(wins)
        let dL = Double(losses)
        let dT = Double(totalMatches - wins - losses)
        
        var ret = [dW, dL, dT, round(number: ((dW + (0.5 * dT)) / Double(totalMatches)) * 100.0, places: 1)]
        
        if totalMatches == 0 {
            ret[ret.count - 1] = 0
        }
        
        return ret
    }
    
    // [won, lost, tied, percent]
    func getMatchResults(p: String, m: [Match]) -> [Double] {
        var wins = 0
        var losses = 0
        var totalMatches = 0
        
        for match in m {
            if match.isInMatch(player: p) {
                if match.getResult(player: p) == Match.WIN {
                    wins += 1
                } else if match.getResult(player: p) == Match.LOSS {
                    losses += 1
                }
                totalMatches += 1
            }
        }
        
        let dW = Double(wins)
        let dL = Double(losses)
        let dT = Double(totalMatches - wins - losses)
        
        var ret = [dW, dL, dT, round(number: ((dW + (0.5 * dT)) / Double(totalMatches)) * 100.0, places: 1)]
        
        if totalMatches == 0 {
            ret[ret.count - 1] = 0
        }
        
        return ret
    }
    
    // [won, lost, tied, percent]
    func getRoundResults(p: String, m: [Match]) -> [Double] {
        var wins = 0
        var losses = 0
        var totalRounds = 0
        
        for match in m {
            for round in match.rounds {
                if round.isInRound(player: p) {
                    if round.getResult(player: p) == Round.WIN {
                        wins += 1
                    } else if round.getResult(player: p) == Round.LOSS {
                        losses += 1
                    }
                    totalRounds += 1
                }
            }
        }
        
        let dW = Double(wins)
        let dL = Double(losses)
        let dT = Double(totalRounds - wins - losses)
        
        return [dW, dL, dT, round(number: ((dW + (0.5 * dT)) / Double(totalRounds)) * 100.0, places: 1)]
    }
    
    func getPointsPerRound(p: String, m: [Match]) -> Double {
        let bagData = getBagData(p: p, m: m)
        return getPointsPerRound(bagData: bagData)
    }
    
    func getPointsPerRound(bagData: [Int]) -> Double {
        let score = Board(bagsIn: bagData[0], bagsOn: bagData[1], bagsOff: bagData[2]).score
        let totalBags = bagData[0] + bagData[1] + bagData[2]
        
        return round(number: Double(score) / Double(3 * totalBags) * 12, places: 2)
    }
    
    // returns [in, on, off]
    func getBagData(p: String, m: [Match]) -> [Int] {
        var totalIn = 0
        var totalOn = 0
        var totalOff = 0
        
        // get sum of bags in, on, and off
        for match in m {
            for round in match.rounds {
                if round.redPlayer == p {
                    totalIn += round.red.bagsIn
                    totalOn += round.red.bagsOn
                    totalOff += round.red.bagsOff
                } else if round.bluePlayer == p {
                    totalIn += round.blue.bagsIn
                    totalOn += round.blue.bagsOn
                    totalOff += round.blue.bagsOff
                }
            }
        }
        
        return [totalIn, totalOn, totalOff]
    }
    
    // standings
    
    @IBAction func openStandings(_ sender: Any) {
        performSegue(withIdentifier: "standingsSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // standings segue
        let controller = segue.destination as! StandingsViewController
        controller.data = getDataForStandings()
    }
    
    func isDoublesLeague() -> Bool {
        for m in matches {
            if m.redPlayers.count == 1 {
                return false
            }
        }
        return true
    }
    
    func isNewTeam(team: [String], soFar: [[String]]) -> Bool {
        for found in soFar {
            if Set(team) == Set(found) {
                return false
            }
        }
        return true
    }
    
    func getAllTeams() -> [[String]] {
        var allTeams = [[String]]()
        for m in matches {
            let reds = m.redPlayers
            let blues = m.bluePlayers
            if isNewTeam(team: reds, soFar: allTeams) {
                allTeams.append(reds)
            }
            if isNewTeam(team: blues, soFar: allTeams) {
                allTeams.append(blues)
            }
        }
        return allTeams
    }
    
    func teamColor(team: [String], match: Match) -> Int {
        if Set(match.redPlayers) == Set(team) {
            return Match.RED
        } else if Set(match.bluePlayers) == Set(team) {
            return Match.BLUE
        } else {
            return Match.NONE
        }
    }
    
    // for each player/team: [won, lost, tied, percent, score/round]
    func getDataForStandings() -> [String : [Double]] {
        if !isDoublesLeague() {
            var matchResults = [String : [Double]]()
            for p in allPlayers {
                matchResults[p] = getMatchResults(p: p, m: matches)
                matchResults[p]?.append(getPointsPerRound(p: p, m: matches))
            }
            return matchResults
        } else {
            var matchResults = [[String] : [Double]]()
            let allTeams = getAllTeams()
            for team in allTeams {
                matchResults[team] = getMatchResults(p: team[0], m: matches)
                var bagData: [Int] = [0, 0, 0]
                for player in team {
                    let data = getBagData(p: player, m: matches)
                    bagData[0] += data[0]
                    bagData[1] += data[1]
                    bagData[2] += data[2]
                }
                matchResults[team]?.append(getPointsPerRound(bagData: bagData))
            }
            var retData = [String : [Double]]()
            for team in matchResults.keys {
                if team.count == 1 {
                    retData[team[0]] = matchResults[team]
                } else {
                    retData["\(team[0])/\(team[1])"] = matchResults[team]
                }
            }
            return retData
        }
    }
}
