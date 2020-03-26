//
//  CornholeLibrary.swift
//  Cornhole
//
//  Created by Alex Wong on 7/3/18.
//  Copyright © 2018 Kids Can Code. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase

let SCOREBOARD_TAB_INDEX = 0
let MATCHES_TAB_INDEX = 1
let STATS_TAB_INDEX = 2
let SETTINGS_TAB_INDEX = 3

let WINNING_SCORE: Int = 21

// color dictionary

let colorKeys = [
    UIColor.red,
    UIColor(red: 0.9, green: 0.45, blue: 0, alpha: 1),
    UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 1),
    UIColor(red: 0, green: 0.6, blue: 0.1, alpha: 1),
    UIColor.blue,
    UIColor.purple,
    UIColor(red: 1, green: 0.08, blue: 0.58, alpha: 1),
    UIColor(red: 0.4, green: 0.26, blue: 0.13, alpha: 1),
    UIColor.darkGray,
    UIColor.black
]

let COLORS = [
    UIColor.red: "Red",
    UIColor(red: 0.9, green: 0.45, blue: 0, alpha: 1): "Orange",
    UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 1): "Yellow",
    UIColor(red: 0, green: 0.6, blue: 0.1, alpha: 1): "Green",
    UIColor.blue: "Blue",
    UIColor.purple: "Purple",
    UIColor(red: 1, green: 0.08, blue: 0.58, alpha: 1): "Pink",
    UIColor(red: 0.4, green: 0.26, blue: 0.13, alpha: 1): "Brown",
    UIColor.darkGray: "Gray",
    UIColor.black: "Black"
]

let systemFont: String = "Century Gothic"
// "Century Gothic"
// "Source Sans Pro"
// "Kefa"
// "Geeza Pro"
// "Hiragino Maru Gothic ProN"
// "Khmer Sangam MN"
// "Gill Sans"
var backgroundImage: UIImage = UIImage(named: "CornholeBackground5.jpg")!

var entryTab: Int = SCOREBOARD_TAB_INDEX

var cachedLeagues: [League] = []

var leaguesPaid = false // todo: IAP
var proPaid = false // todo: IAP

class Board {
    var bagsIn: Int
    var bagsOn: Int
    var bagsOff: Int
    var score: Int
    
    init(bagsIn: Int, bagsOn: Int, bagsOff: Int) {
        self.bagsIn = bagsIn
        self.bagsOn = bagsOn
        self.bagsOff = bagsOff
        self.score = (bagsIn * 3) + bagsOn
    }
}

class Round: CustomStringConvertible {
    static let RED = 0
    static let BLUE = 1
    static let TIE = 2
    static let WIN = 3
    static let LOSS = 4
    
    var red: Board
    var blue: Board
    var redMatchScore: Int
    var blueMatchScore: Int
    var winner: Int
    var redPlayer: String
    var bluePlayer: String
    
    init(red: Board, blue: Board, redPlayer: String, bluePlayer: String) {
        self.red = red
        self.blue = blue
        self.redPlayer = redPlayer
        self.bluePlayer = bluePlayer
        
        // determine winner
        if red.score > blue.score {
            winner = Round.RED
            redMatchScore = red.score - blue.score
            blueMatchScore = 0
        } else if blue.score > red.score {
            winner = Round.BLUE
            blueMatchScore = blue.score - red.score
            redMatchScore = 0
        } else {
            winner = Round.TIE
            redMatchScore = 0
            blueMatchScore = 0
        }
    }
    
    func getResult(player: String) -> Int {
        if redPlayer == player && winner == Round.RED {
            return Round.WIN
        } else if bluePlayer == player && winner == Round.BLUE {
            return Round.WIN
        } else if winner == Round.TIE {
            return Round.TIE
        } else {
            return Round.LOSS
        }
    }
    
    func isInRound(player: String) -> Bool {
        return [redPlayer, bluePlayer].contains(player)
    }
    
    public var description: String {
        return "\(redPlayer) \(red.score) - \(blue.score) \(bluePlayer)"
    }
}

class Match: CustomStringConvertible {
    static let RED = 0
    static let BLUE = 1
    static let TIE = 2
    static let NONE = 3
    static let WIN = 4
    static let LOSS = 5
    
    static var universalID: Int = 0 // universal incrementing id
    
    var redPlayers: [String]
    var bluePlayers: [String]
    var rounds: [Round]
    var redScore: Int
    var blueScore: Int
    var winner: Int
    var id: Int
    var firebaseID: String = ""
    var startDate: Date
    var endDate: Date
    var redColor: UIColor // note: can be ANY color
    var blueColor: UIColor
    var gameSettings: GameSettings
    
    // used for only temp storage
    init(redPlayers: [String], bluePlayers: [String], rounds: [Round], gameSettings: GameSettings) {
        self.gameSettings = gameSettings
        self.redPlayers = redPlayers
        self.bluePlayers = bluePlayers
        self.rounds = rounds
        self.redScore = 0
        self.blueScore = 0
        self.winner = Match.NONE
        
        self.id = Match.universalID
        Match.universalID += 1
        
        self.startDate = Date()
        self.endDate = Date()
        
        self.redColor = UIColor.red
        self.blueColor = UIColor.blue
        
        self.winner = determineWinner()
    }
    
    init(redPlayers: [String], bluePlayers: [String], rounds: [Round], id: Int, start: Date, end: Date, redColor: UIColor, blueColor: UIColor, gameSettings: GameSettings) {
        self.gameSettings = gameSettings
        self.redPlayers = redPlayers
        self.bluePlayers = bluePlayers
        self.rounds = rounds
        self.redScore = 0
        self.blueScore = 0
        self.winner = Match.NONE
        
        self.id = id
        
        self.startDate = start
        self.endDate = end
        
        self.redColor = redColor
        self.blueColor = blueColor
        
        self.winner = determineWinner()
    }
    
    init(redPlayers: [String], bluePlayers: [String], rounds: [Round], id: Int, firebaseID: String, start: Date, end: Date, redColor: UIColor, blueColor: UIColor, gameSettings: GameSettings) {
        self.gameSettings = gameSettings
        self.redPlayers = redPlayers
        self.bluePlayers = bluePlayers
        self.rounds = rounds
        self.redScore = 0
        self.blueScore = 0
        self.winner = Match.NONE
        
        self.id = id
        self.firebaseID = firebaseID
        
        self.startDate = start
        self.endDate = end
        
        self.redColor = redColor
        self.blueColor = blueColor
        
        self.winner = determineWinner()
    }
    
    func addRound(round: Round) {
        rounds.append(round)
        
        winner = determineWinner()
    }
    
    func calculateScores() {
        redScore = getTeamScoreAfterRound(team: Match.RED, round: rounds.count)
        blueScore = getTeamScoreAfterRound(team: Match.BLUE, round: rounds.count)
    }
    
    func determineWinner() -> Int {
        calculateScores()
        
        switch gameSettings.gameType {
        case .standard:
            if redScore >= gameSettings.winningScore {
                return Match.RED
            } else if blueScore >= gameSettings.winningScore {
                return Match.BLUE
            } else {
                return Match.NONE
            }
        case .bust:
            if redScore == gameSettings.winningScore {
                return Match.RED
            } else if blueScore == gameSettings.winningScore {
                return Match.BLUE
            } else {
                return Match.NONE
            }
        case .rounds:
            if rounds.count >= gameSettings.roundLimit {
                if redScore > blueScore {
                    return Match.RED
                } else if blueScore > redScore {
                    return Match.BLUE
                } else {
                    return Match.TIE
                }
            } else {
                return Match.NONE
            }
        }
    }
    
    func isInMatch(player: String) -> Bool {
        return (redPlayers + bluePlayers).contains(player)
    }
    
    func getResult(player: String) -> Int {
        if winner == Match.TIE {
            return Match.TIE
        } else if redPlayers.contains(player) && winner == Match.RED {
            return Match.WIN
        } else if bluePlayers.contains(player) && winner == Match.BLUE {
            return Match.WIN
        } else {
            return Match.LOSS
        }
    }
    
    // returns "(score) - (score)"
    private func getScoreline(red: Int, blue: Int) -> String {
        return "\(red) - \(blue)"
    }
    
    // 1-indexed
    func getScoreAfterRound(round: Int) -> String {
        let redTempScore = getTeamScoreAfterRound(team: Match.RED, round: round)
        let blueTempScore = getTeamScoreAfterRound(team: Match.BLUE, round: round)
        
        return getScoreline(red: redTempScore, blue: blueTempScore)
    }
    
    func getTeamScoreAfterRound(team: Int, round: Int) -> Int {
        var tmpScore = 0
        
        for i in 0..<round {
            if team == Match.RED {
                switch gameSettings.gameType {
                case .standard:
                    tmpScore += rounds[i].redMatchScore
                case .bust:
                    tmpScore += rounds[i].redMatchScore
                    if tmpScore > gameSettings.winningScore {
                        tmpScore = gameSettings.bustScore
                    }
                case .rounds:
                    tmpScore += rounds[i].redMatchScore
                }
            } else if team == Match.BLUE {
                switch gameSettings.gameType {
                case .standard:
                    tmpScore += rounds[i].blueMatchScore
                case .bust:
                    tmpScore += rounds[i].blueMatchScore
                    if tmpScore > gameSettings.winningScore {
                        tmpScore = gameSettings.bustScore
                    }
                case .rounds:
                    tmpScore += rounds[i].blueMatchScore
                }
            }
        }
        
        return tmpScore
    }
    
    public var description: String {
        if redPlayers.count == 1 {
            return "\(redPlayers[0]) \(getScoreline(red: redScore, blue: blueScore)) \(bluePlayers[0])"
        } else {
            return "\(redPlayers[0]), \(redPlayers[1]) \(getScoreline(red: redScore, blue: blueScore)) \(bluePlayers[0]), \(bluePlayers[1])"
        }
    }
    
    // change player name in match, returns if something was changed
    func changePlayerNames(froms: [String], tos: [String]) -> Bool {
        var ret = false
        for i in 0..<redPlayers.count {
            if let index = froms.firstIndex(of: redPlayers[i]) {
                ret = true
                redPlayers[i] = tos[index]
            }
            if let index = froms.firstIndex(of: bluePlayers[i]) {
                ret = true
                bluePlayers[i] = tos[index]
            }
        }
        for r in rounds {
            if let index = froms.firstIndex(of: r.redPlayer) {
                ret = true
                r.redPlayer = tos[index]
            }
            if let index = froms.firstIndex(of: r.bluePlayer) {
                ret = true
                r.bluePlayer = tos[index]
            }
        }
        if froms == tos {
            ret = false
        }
        return ret
    }
    
    // get round players
    
    func getRoundPlayers() -> [String] {
        var roundPlayers: [String] = []
        for round in 0..<(self.rounds).count {
            roundPlayers.append((self.rounds[round].redPlayer))
            roundPlayers.append((self.rounds[round].bluePlayer))
        }
        return roundPlayers
    }
    
    func getRoundData() -> [Int] { // red in, red on, red off, blue in, blue on, blue off
        var roundData: [Int] = []
        for round in 0..<(self.rounds).count {
            roundData.append((self.rounds[round].red.bagsIn))
            roundData.append((self.rounds[round].red.bagsOn))
            roundData.append((self.rounds[round].red.bagsOff))
            roundData.append((self.rounds[round].blue.bagsIn))
            roundData.append((self.rounds[round].blue.bagsOn))
            roundData.append((self.rounds[round].blue.bagsOff))
        }
        return roundData
    }
    
    // import a match
    
    static func importData(from url: URL) {
        
        guard let dictionary = NSDictionary(contentsOf: url),
            let matchInfo = dictionary as? [String : AnyObject],
            let playerNames = matchInfo["playerNames"] as? [String],
            let roundPlayers = matchInfo["roundPlayers"] as? [String],
            let roundData = matchInfo["roundData"] as? [Int],
            var id = matchInfo["id"] as? Int,
            let startDate = matchInfo["startDate"] as? Date,
            let endDate = matchInfo["endDate"] as? Date,
            let redColorRGBA = matchInfo["redColorRGBA"] as? [CGFloat],
            let blueColorRGBA = matchInfo["blueColorRGBA"] as? [CGFloat]
            else {
                return
        }
        
        let gameType = matchInfo["gameType"] != nil ? matchInfo["gameType"] as! Int : GameType.standard.rawValue
        let winningScore = matchInfo["winningScore"] != nil ? matchInfo["winningScore"] as! Int : WINNING_SCORE_DEFAULT
        let bustScore = matchInfo["bustScore"] != nil ? matchInfo["bustScore"] as! Int : NOT_APPLICABLE
        let roundLimit = matchInfo["roundLimit"] != nil ? matchInfo["roundLimit"] as! Int : NOT_APPLICABLE
        
        // update id
        
        let matches = getMatchesFromCoreData()
        id = getNewID(matches: matches)
        
        // create colors
        let redColor = UIColor(red: redColorRGBA[0], green: redColorRGBA[1], blue: redColorRGBA[2], alpha: redColorRGBA[3])
        let blueColor = UIColor(red: blueColorRGBA[0], green: blueColorRGBA[1], blue: blueColorRGBA[2], alpha: blueColorRGBA[3])
        
        // save match data core data
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newUser = NSEntityDescription.insertNewObject(forEntityName: "Matches", into: context)
        newUser.setValue(playerNames, forKey: "playerNamesArray")
        newUser.setValue(roundPlayers, forKey: "roundPlayersArray")
        newUser.setValue(roundData, forKey: "roundDataArray")
        newUser.setValue(id, forKey: "id")
        newUser.setValue(startDate, forKey: "startDate")
        newUser.setValue(endDate, forKey: "endDate")
        newUser.setValue(redColor, forKey: "redColor")
        newUser.setValue(blueColor, forKey: "blueColor")
        newUser.setValue(gameType, forKey: "gameType")
        newUser.setValue(winningScore, forKey: "winningScore")
        newUser.setValue(bustScore, forKey: "bustScore")
        newUser.setValue(roundLimit, forKey: "roundLimit")
        
        do {
            try context.save()
            print("Saved")
        } catch {
            print("Error")
        }
        
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Failed to remove item from Inbox")
        }
    }
    
    // export a match
    
    func exportToFileURL() -> URL? {
        
        var contents = [String : Any]()
        
        let allPlayers: [String] = redPlayers + bluePlayers
        contents["playerNames"] = allPlayers
        
        var roundPlayers: [String] = []
        var roundData: [Int] = [] // red in, red on, red off, blue in, blue on, blue off
        
        for round in 0..<rounds.count {
            roundPlayers.append(rounds[round].redPlayer)
            roundPlayers.append(rounds[round].bluePlayer)
            
            // add board data
            roundData.append(rounds[round].red.bagsIn)
            roundData.append(rounds[round].red.bagsOn)
            roundData.append(rounds[round].red.bagsOff)
            roundData.append(rounds[round].blue.bagsIn)
            roundData.append(rounds[round].blue.bagsOn)
            roundData.append(rounds[round].blue.bagsOff)
        }
        
        contents["roundPlayers"] = roundPlayers
        contents["roundData"] = roundData
        contents["id"] = id
        contents["startDate"] = startDate
        contents["endDate"] = endDate
        contents["gameType"] = gameSettings.gameType.rawValue
        contents["winningScore"] = gameSettings.winningScore
        contents["bustScore"] = gameSettings.bustScore
        contents["roundLimit"] = gameSettings.roundLimit
        
        // colors
        var rR: CGFloat = 0, rG: CGFloat = 0, rB: CGFloat = 0, rA: CGFloat = 0
        redColor.getRed(&rR, green: &rG, blue: &rB, alpha: &rA)
        contents["redColorRGBA"] = [rR, rG, rB, rA]
        var bR: CGFloat = 0, bG: CGFloat = 0, bB: CGFloat = 0, bA: CGFloat = 0
        blueColor.getRed(&bR, green: &bG, blue: &bB, alpha: &bA)
        contents["blueColorRGBA"] = [bR, bG, bB, bA]
 
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let saveFileURL = path.appendingPathComponent("/match\(id).corn")
        (contents as NSDictionary).write(to: saveFileURL, atomically: true)
        return saveFileURL
    }
}

class League {
    
    var name: String = ""
    var players: [String] = []
    var matches: [Match] = []
    var ownerID: String = ""
    var editorEmails: [String] = []
    var firebaseID: String = ""
    var firstThrowWinners: Bool = true
    var gameSettings: GameSettings = GameSettings.init()
    
    static let NEW_ID_FAILED: String = ""
    
    init() {
    }
    
    init(name: String, owner: User) {
        self.name = name
        self.firebaseID = League.NEW_ID_FAILED // placeholder if fails
        self.ownerID = owner.uid
        self.editorEmails = [owner.email!]
    }
    
    init(name: String, firebaseID: String, owner: User) {
        self.name = name
        self.firebaseID = firebaseID
        self.ownerID = owner.uid
        self.editorEmails = [owner.email!]
    }
    
    func isOwner(user: User?) -> Bool {
        if let u = user {
            return u.uid == ownerID
        }
        return false
    }
    
    func isEditor(user: User?) -> Bool {
        if let email = user?.email {
            return editorEmails.contains(email)
        }
        return false
    }
}

// other methods

// is any league active
func isLeagueActive() -> Bool {
    return UserDefaults.getActiveLeagueID() != CornholeFirestore.TEST_LEAGUE_ID
}

// get all players from an array of matches
func getMatchPlayers(array: [Match]) -> [String] {
    var retNames: [String] = []
    
    for match in array {
        for player in match.redPlayers + match.bluePlayers {
            if !retNames.contains(player) { // if new player
                if player != "Player 1" && player != "Player 2" { // exclude guests
                    retNames.append(player)
                }
            }
        }
    }
    
    return retNames.sorted()
}

// works for matches or rounds (req: nowhere else is there a " - ")
func colorDescription(str: String, size: CGFloat, redColor: UIColor, blueColor: UIColor) -> NSMutableAttributedString {
    let descArray = str.components(separatedBy: " - ")
    
    let mutableString = NSMutableAttributedString(string: str, attributes: [NSAttributedString.Key.font: UIFont(name: systemFont, size: size)!])
    mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: redColor, range: NSRange(location: 0, length: descArray[0].count))
    mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: blueColor, range: NSRange(location: str.count - descArray[1].count, length: descArray[1].count))
    
    return mutableString
}

func round(number: Double, places: Int) -> Double {
    let multiplier: Double = Double(truncating: pow(10, places) as NSNumber)
    
    return Double(round(number * multiplier) / multiplier)
}

func getNewID(matches: [Match]) -> Int {
    var allIDs: [Int] = []
    for match in matches {
        allIDs.append(match.id)
    }
    
    var cur = 0
    while true {
        if !allIDs.contains(cur) {
            return cur
        } else {
            cur += 1
        }
    }
}

func hasTraits(view: UIView, width: UIUserInterfaceSizeClass, height: UIUserInterfaceSizeClass) -> Bool {
    return view.traitCollection.horizontalSizeClass == width && view.traitCollection.verticalSizeClass == height
}

// iphone se, 5, etc
func smallDevice() -> Bool {
    if UIDevice().userInterfaceIdiom == .phone {
        if UIScreen.main.nativeBounds.height <= 1136 { // iphone 5, 5s, 5c, se
            return true
        } else if UIScreen.main.nativeBounds.size.height == 1334 && UIScreen.main.nativeScale > UIScreen.main.scale { // zoomed iphone 6/6s/7/8
            return true
        }
    }
    return false
}

// ipads
func bigDevice() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}

// core data methods

func coreDataDeleteAll(entity: String) {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let context = appDelegate.persistentContainer.viewContext
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
    request.returnsObjectsAsFaults = false
    
    // delete all
    let result = try? context.fetch(request)
    let resultData = result as! [NSManagedObject]
    for object in resultData {
        context.delete(object)
    }
    
    do {
        try context.save()
        print("Saved delete")
    } catch let error as NSError {
        print("Could not save \(error), \(error.userInfo)")
    } catch {
        
    }
}

func getMatchesFromCoreData() -> [Match] {
    var retMatches: [Match] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let context = appDelegate.persistentContainer.viewContext
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Matches")
    request.returnsObjectsAsFaults = false
    
    var ids: [Int] = []
    var playerNames: [[String]] = [] // [[match 1 names], [match 2 names], ...]
    var roundPlayers: [[String]] = [] // [[match 1 round 1 players, match 1 round 2 players], ...]
    var roundData: [[Int]] = [] // [[red in, red on, red off, blue in, blue on, blue off, ...], ...]
    var startDates: [Date] = []
    var endDates: [Date] = []
    var redColors: [UIColor] = []
    var blueColors: [UIColor] = []
    var gameTypes: [Int] = []
    var winningScores: [Int] = []
    var bustScores: [Int] = []
    var roundLimits: [Int] = []
    
    do {
        let results = try context.fetch(request)
        
        if results.count > 0 {
            for result in results as! [NSManagedObject] {
                if let idNum = result.value(forKey: "id") as? Int {
                    ids.append(idNum)
                }
                
                if let pNames = result.value(forKey: "playerNamesArray") as? [String] {
                    playerNames.append(pNames)
                }
                
                if let rPlayers = result.value(forKey: "roundPlayersArray") as? [String] {
                    roundPlayers.append(rPlayers)
                }
                
                if let rData = result.value(forKey: "roundDataArray") as? [Int] {
                    roundData.append(rData)
                }
                
                if let sDate = result.value(forKey: "startDate") as? Date {
                    startDates.append(sDate)
                }
                
                if let eDate = result.value(forKey: "endDate") as? Date {
                    endDates.append(eDate)
                }
                
                if let rColor = result.value(forKey: "redColor") as? UIColor {
                    redColors.append(rColor)
                }
                
                if let bColor = result.value(forKey: "blueColor") as? UIColor {
                    blueColors.append(bColor)
                }
                
                if let gType = result.value(forKey: "gameType") as? Int {
                    gameTypes.append(gType)
                }
                
                if let wScore = result.value(forKey: "winningScore") as? Int {
                    winningScores.append(wScore)
                }
                
                if let bScore = result.value(forKey: "bustScore") as? Int {
                    bustScores.append(bScore)
                }
                
                if let rLimit = result.value(forKey: "roundLimit") as? Int {
                    roundLimits.append(rLimit)
                }
            }
        }
    } catch {
        print("Error")
    }
    
    if playerNames.count != 0 { // if there has been a match played
        for matchNum in 0..<playerNames.count { // gets a match #
            
            retMatches.append(getMatchFromRawData(playerNames: playerNames[matchNum], roundPlayers: roundPlayers[matchNum], roundData: roundData[matchNum], id: ids[matchNum], startDate: startDates[matchNum], endDate: endDates[matchNum], redColor: redColors[matchNum], blueColor: blueColors[matchNum], gameType: gameTypes[matchNum], winningScore: winningScores[matchNum], bustScore: bustScores[matchNum], roundLimit: roundLimits[matchNum]))
        }
    }
    
    // sort by date
    retMatches = retMatches.sorted(by: { $0.startDate.compare($1.startDate) == .orderedDescending })
    
    print(gameTypes)
    print(winningScores)
    print(bustScores)
    print(roundLimits)
    
    return retMatches
}

// other data methods

func getMatchFromRawData(playerNames: [String], roundPlayers: [String], roundData: [Int], id: Int, firebaseID: String = "", startDate: Date, endDate: Date, redColor: UIColor, blueColor: UIColor, gameType: Int, winningScore: Int, bustScore: Int, roundLimit: Int) -> Match {
    
    var thisMatchRounds: [Round] = []
    
    for roundNum in 0...((roundData.count / 6) - 1) { // gets a round #
        thisMatchRounds.append(Round(red: Board(bagsIn: roundData[roundNum * 6], bagsOn: roundData[roundNum * 6 + 1], bagsOff: roundData[roundNum * 6 + 2]), blue: Board(bagsIn: roundData[roundNum * 6 + 3], bagsOn: roundData[roundNum * 6 + 4], bagsOff: roundData[roundNum * 6 + 5]), redPlayer: roundPlayers[roundNum * 2], bluePlayer: roundPlayers[roundNum * 2 + 1]))
    }
    
    // get game type
    let actualGameType: GameType = GameType(rawValue: gameType) ?? GameType.standard
    
    let gameSettings = GameSettings(gameType: actualGameType, winningScore: winningScore, bustScore: bustScore, roundLimit: roundLimit)
    
    if playerNames.count == 2 {
        return Match(redPlayers: [playerNames[0]], bluePlayers: [playerNames[1]], rounds: thisMatchRounds, id: id, firebaseID: firebaseID, start: startDate, end: endDate, redColor: redColor, blueColor: blueColor, gameSettings: gameSettings)
    } else {
        return Match(redPlayers: [playerNames[0], playerNames[1]], bluePlayers: [playerNames[2], playerNames[3]], rounds: thisMatchRounds, id: id, firebaseID: firebaseID, start: startDate, end: endDate, redColor: redColor, blueColor: blueColor, gameSettings: gameSettings)
    }
}

// csv export

let CSV_MATCH_INDEX = 0
let CSV_ROUND_INDEX = 1
let CSV_PLAYER_INDEX = 2
let CSV_COLOR_INDEX = 3
let CSV_BAGS_IN_INDEX = 4
let CSV_BAGS_ON_INDEX = 5
let CSV_BAGS_OFF_INDEX = 6
let CSV_SCORE_INDEX = 7
let CSV_TEAM_ROUND_SCORE_INDEX = 8
let CSV_TEAM_TOTAL_SCORE_INDEX = 9

func getCSVText(matches: [Match]) -> String {
    
    var csvText = "Match,Round,Player,Color,Bags In,Bags On,Bags Off,Score,Team Round Score,Team Total Score\n"
    
    // get data
    for m in 0..<matches.count {
        let thisMatch = matches[m]
        for r in 0..<thisMatch.rounds.count {
            let thisRound = thisMatch.rounds[r]
            
            let redString = "\(m + 1),\(r + 1),\(thisRound.redPlayer),Red,\(thisRound.red.bagsIn),\(thisRound.red.bagsOn),\(thisRound.red.bagsOff),\(thisRound.red.score),\(thisRound.redMatchScore),\(thisMatch.getTeamScoreAfterRound(team: Match.RED, round: r + 1))\n"
            
            let blueString = "\(m + 1),\(r + 1),\(thisRound.bluePlayer),Blue,\(thisRound.blue.bagsIn),\(thisRound.blue.bagsOn),\(thisRound.blue.bagsOff),\(thisRound.blue.score),\(thisRound.blueMatchScore),\(thisMatch.getTeamScoreAfterRound(team: Match.BLUE, round: r + 1))\n"
            
            if thisMatch.redPlayers.count == 1 { // 1v1
                if r % 2 == 0 { // red first
                    csvText.append(redString)
                    csvText.append(blueString)
                } else { // blue first
                    csvText.append(blueString)
                    csvText.append(redString)
                }
            } else { // 2v2
                if r % 4 == 0 || r % 4 == 1 { // red first
                    csvText.append(redString)
                    csvText.append(blueString)
                } else {
                    csvText.append(blueString)
                    csvText.append(redString)
                }
            }
        }
    }
    
    return csvText
}

// game type

enum GameType: Int {
    // 21 or over wins, over 21 go back down, set number of rounds
    case standard = 0, bust, rounds
}

let WINNING_SCORE_DEFAULT = 21
let BUST_SCORE_DEFAULT = 15
let ROUND_LIMIT_DEFAULT = 10
let NOT_APPLICABLE = -1

struct GameSettings: Equatable {
    
    var gameType: GameType
    var winningScore: Int
    var bustScore: Int // score to go back to
    var roundLimit: Int
    
    // default game from version up to 2.1
    init() {
        self.gameType = .standard
        self.winningScore = WINNING_SCORE_DEFAULT
        self.bustScore = NOT_APPLICABLE
        self.roundLimit = NOT_APPLICABLE
    }
    
    init(gameType: GameType, winningScore: Int) {
        self.gameType = gameType
        self.winningScore = winningScore
        self.bustScore = NOT_APPLICABLE
        self.roundLimit = NOT_APPLICABLE
    }
    
    init(gameType: GameType, winningScore: Int, bustScore: Int) {
        self.gameType = gameType
        self.winningScore = winningScore
        self.bustScore = bustScore
        self.roundLimit = NOT_APPLICABLE
    }
    
    init(gameType: GameType, roundLimit: Int) {
        self.gameType = gameType
        self.winningScore = NOT_APPLICABLE
        self.bustScore = NOT_APPLICABLE
        self.roundLimit = roundLimit
    }
    
    init(gameType: GameType, winningScore: Int, bustScore: Int, roundLimit: Int) {
        self.gameType = gameType
        self.winningScore = winningScore
        self.bustScore = bustScore
        self.roundLimit = roundLimit
    }
    
    static func == (lhs: GameSettings, rhs: GameSettings) -> Bool {
        return lhs.gameType == rhs.gameType &&
            lhs.winningScore == rhs.winningScore &&
            lhs.bustScore == rhs.bustScore &&
            lhs.roundLimit == rhs.roundLimit
    }
}

// defaults

extension UserDefaults {
    static func getLeagueIDs() -> [String] {
        let defaults = UserDefaults.standard
        return defaults.array(forKey: "leagueIDs") as? [String] ?? []
    }

    static func setLeagueIDs(ids: [String]) {
        let defaults = UserDefaults.standard
        defaults.set(ids, forKey: "leagueIDs")
    }
    
    static func getActiveLeagueID() -> String {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "activeLeagueID") ?? ""
    }
    
    static func setActiveLeagueID(id: String) {
        let defaults = UserDefaults.standard
        defaults.set(id, forKey: "activeLeagueID")
    }
    
    static func addLeagueID(id: String) {
        var oldIDs = getLeagueIDs()
        oldIDs.append(id)
        setLeagueIDs(ids: oldIDs)
    }
    
    // remove at index
    static func removeLeagueID(at: Int) {
        var oldIDs = getLeagueIDs()
        let leagueID = oldIDs[at]
        oldIDs.remove(at: at)
        setLeagueIDs(ids: oldIDs)
        cachedLeagues.removeAll { $0.firebaseID == leagueID }
    }
    
    static func removeLeagueID(id: String) {
        var oldIDs = getLeagueIDs()
        oldIDs.removeAll { $0 == id }
        setLeagueIDs(ids: oldIDs)
        cachedLeagues.removeAll { $0.firebaseID == id }
    }
    
    // pull from cached leagues
    static func getActiveLeague() -> League? {
        return getCachedLeague(id: getActiveLeagueID())
    }
}

// firebase

class CornholeFirestore {
    
    static let TEST_LEAGUE_ID: String = ""

    private static func readField(collection: String, document: String, field: String, completion: @escaping (Any?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection(collection).document(document).getDocument { (snapshot, error) in
            if let snapshot = snapshot, snapshot.exists {
                if let snapshotData = snapshot.data() {
                    completion(snapshotData[field], nil)
                } else if let error = error {
                    completion(nil, error)
                } else {
                    completion(nil, nil)
                }
            } else if let error = error {
                completion(nil, error)
            } else {
                completion(nil, nil)
            }
        }
    }

    private static func updateField(collection: String, document: String, field: String, value: Any) {
        let db = Firestore.firestore()
        db.collection(collection).document(document).updateData([field: value])
    }
    
    static func createLeague(league: League) {
        let db = Firestore.firestore()
        
        let emptyStrings = [String]()
        let emptyInts = [Int]()
        let emptyTimestamps = [Timestamp]()
        
        var ref: DocumentReference? = nil
        ref = db.collection("leagues").addDocument(
        data: ["name": league.name,
               "ownerID": league.ownerID,
               "editorEmails": league.editorEmails,
               "players": emptyStrings,
               "firstThrowWinners": true,
               "gameType": GameType.standard.rawValue,
               "winningScore": WINNING_SCORE_DEFAULT,
               "bustScore": BUST_SCORE_DEFAULT,
               "roundLimit": ROUND_LIMIT_DEFAULT,
               "matchBustScores": emptyInts,
               "matchColors": emptyStrings,
               "matchEndDates": emptyTimestamps,
               "matchGameTypes": emptyInts,
               "matchMatchIDs": emptyInts,
               "matchPlayerNamesArrays": emptyStrings,
               "matchRoundDataArrays": emptyStrings,
               "matchRoundLimits": emptyInts,
               "matchRoundPlayersArrays": emptyStrings,
               "matchStartDates": emptyTimestamps,
               "matchWinningScores": emptyInts
        ]) { err in
            if let err = err {
                print("error adding match: \(err)")
            }
        }
        updateField(collection: "leagues", document: ref!.documentID, field: "id", value: ref!.documentID)
        league.firebaseID = ref!.documentID
        cachedLeagues.append(league)
        
    }
    
    static func addEditorToLeague(leagueID: String, editorEmail: String) {
        let db = Firestore.firestore()
        if let league = getCachedLeague(id: leagueID) {
            league.editorEmails.append(editorEmail)
            db.collection("leagues").document(league.firebaseID).updateData(["editorEmails": league.editorEmails])
        }
    }
    
    static func deleteEditorFromLeague(leagueID: String, editorEmail: String) {
        let db = Firestore.firestore()
        if let league = getCachedLeague(id: leagueID) {
            league.editorEmails.removeAll { $0 == editorEmail }
            db.collection("leagues").document(league.firebaseID).updateData(["editorEmails": league.editorEmails])
        }
    }
    
    static func addPlayerToLeague(leagueID: String, playerName: String) {
        let db = Firestore.firestore()
        if let league = getCachedLeague(id: leagueID) {
            league.players.append(playerName)
            db.collection("leagues").document(league.firebaseID).updateData(["players": league.players])
        }
    }
    
    static func addPlayersToLeague(leagueID: String, playerNames: [String]) {
        let db = Firestore.firestore()
        if let league = getCachedLeague(id: leagueID) {
            league.players.append(contentsOf: playerNames)
            db.collection("leagues").document(league.firebaseID).updateData(["players": league.players])
        }
    }
    
    static func deletePlayerFromLeague(leagueID: String, playerName: String) {
        let db = Firestore.firestore()
        if let league = getCachedLeague(id: leagueID) {
            league.players.removeAll { $0 == playerName }
            db.collection("leagues").document(league.firebaseID).updateData(["players": league.players])
        }
    }
    
    static func changePlayerName(leagueID: String, from: String, to: String) {
        let db = Firestore.firestore()
        
        if let league = getCachedLeague(id: leagueID) {
            for i in 0..<league.players.count {
                if league.players[i] == from {
                    league.players[i] = to
                }
            }
            
            var hasChanged = false
            for m in league.matches {
                hasChanged = m.changePlayerNames(froms: [from], tos: [to]) || hasChanged
            }
            
            if hasChanged {
                db.collection("leagues").document(league.firebaseID).updateData(["players": league.players, "matchPlayerNamesArrays": getDataFromMatches(matches: league.matches)["matchPlayerNamesArrays"]!])
            } else {
                db.collection("leagues").document(league.firebaseID).updateData(["players": league.players])
            }
        }
    }
    
    static func addMatchToLeague(leagueID: String, match: Match) {
        let db = Firestore.firestore()
        if let league = getCachedLeague(id: leagueID) {
            league.matches.append(match)
            db.collection("leagues").document(leagueID).updateData(getDataFromMatches(matches: league.matches))
        }
    }
    
    static func setLeagueMatches(leagueID: String, matches: [Match]) {
        let db = Firestore.firestore()
        if let league = getCachedLeague(id: leagueID) {
            league.matches = matches
            db.collection("leagues").document(leagueID).updateData(getDataFromMatches(matches: matches))
        }
    }
    
    static func deleteMatchFromLeague(leagueID: String, index: Int) {
        let db = Firestore.firestore()
        if let league = getCachedLeague(id: leagueID) {
            league.matches.remove(at: index)
            db.collection("leagues").document(leagueID).updateData(getDataFromMatches(matches: league.matches))
        }
    }
    
    static func deleteAllMatchesFromLeague(leagueID: String) {
        let db = Firestore.firestore()
        if let league = getCachedLeague(id: leagueID) {
            league.matches.removeAll()
            db.collection("leagues").document(leagueID).updateData(getDataFromMatches(matches: league.matches))
        }
    }
    /*
    static func getDataFromMatch(leagueID: String, match: Match) -> [String : Any] {
        var ret: [String : Any] = [:]
        ret["playerNamesArray"] = encodePlayerNames(playerNames: match.redPlayers + match.bluePlayers)
        ret["roundPlayersArray"] = encodeRoundPlayers(roundPlayers: match.getRoundPlayers(), redPlayers: match.redPlayers, bluePlayers: match.bluePlayers)
        ret["roundDataArray"] = encodeRoundData(roundData: match.getRoundData())
        ret["matchID"] = match.id
        ret["colors"] = encodeColors(redColor: match.redColor, blueColor: match.blueColor)
        ret["startDate"] = Timestamp.init(date: match.startDate)
        ret["endDate"] = Timestamp.init(date: match.endDate)
        ret["gameType"] = match.gameSettings.gameType.rawValue
        ret["winningScore"] = match.gameSettings.winningScore
        ret["bustScore"] = match.gameSettings.bustScore
        ret["roundLimit"] = match.gameSettings.roundLimit
        return ret
    }
    */
    static private func getDataFromMatches(matches: [Match]) -> [String : Any] {
        let emptyStrings = [String]()
        let emptyInts = [Int]()
        let emptyTimestamps = [Timestamp]()
        
        var _matchbustScores = emptyInts
        var _matchColors = emptyStrings
        var _matchEndDates = emptyTimestamps
        var _matchGameTypes = emptyInts
        var _matchMatchIDs = emptyInts
        var _matchPlayerNamesArrays = emptyStrings
        var _matchRoundDataArrays = emptyStrings
        var _matchRoundLimits = emptyInts
        var _matchRoundPlayersArrays = emptyStrings
        var _matchStartDates = emptyTimestamps
        var _matchWinningScores = emptyInts
        
        for m in matches {
            _matchbustScores.append(m.gameSettings.bustScore)
            _matchColors.append(encodeColors(redColor: m.redColor, blueColor: m.blueColor))
            _matchEndDates.append(Timestamp.init(date: m.endDate))
            _matchGameTypes.append(m.gameSettings.gameType.rawValue)
            _matchMatchIDs.append(m.id)
            _matchPlayerNamesArrays.append(encodePlayerNames(playerNames: m.redPlayers + m.bluePlayers))
            _matchRoundDataArrays.append(encodeRoundData(roundData: m.getRoundData()))
            _matchRoundLimits.append(m.gameSettings.roundLimit)
            _matchRoundPlayersArrays.append(encodeRoundPlayers(roundPlayers: m.getRoundPlayers(), redPlayers: m.redPlayers, bluePlayers: m.bluePlayers))
            _matchStartDates.append(Timestamp.init(date: m.startDate))
            _matchWinningScores.append(m.gameSettings.winningScore)
        }
        
        return ["matchBustScores": _matchbustScores,
                "matchColors": _matchColors,
                "matchEndDates": _matchEndDates,
                "matchGameTypes": _matchGameTypes,
                "matchMatchIDs": _matchMatchIDs,
                "matchPlayerNamesArrays": _matchPlayerNamesArrays,
                "matchRoundDataArrays": _matchRoundDataArrays,
                "matchRoundLimits": _matchRoundLimits,
                "matchRoundPlayersArrays": _matchRoundPlayersArrays,
                "matchStartDates": _matchStartDates,
                "matchWinningScores": _matchWinningScores]
    }
    
    static private func encodePlayerNames(playerNames: [String]) -> String {
        var ret = ""
        for player in playerNames {
            ret += player
            ret += ";"
        }
        return ret
    }
    
    static private func decodePlayerNames(encoded: String) -> [String] {
        var ret = [String]()
        let e = encoded.split(separator: ";")
        for p in e {
            let s = String(p)
            if s.count > 0 {
                ret.append(s)
            }
        }
        return ret
    }
    
    static private func encodeRoundPlayers(roundPlayers: [String], redPlayers: [String], bluePlayers: [String]) -> String {
        var playerCodes = [String : String]()
        if redPlayers.count == 1 {
            playerCodes[redPlayers[0]] = "0"
            playerCodes[bluePlayers[0]] = "1"
        } else {
            playerCodes[redPlayers[0]] = "0"
            playerCodes[redPlayers[1]] = "1"
            playerCodes[bluePlayers[0]] = "2"
            playerCodes[bluePlayers[1]] = "3"
        }
        var ret = ""
        for player in roundPlayers {
            ret += playerCodes[player] ?? ""
        }
        return ret
    }
    
    static private func decodeRoundPlayers(encoded: String, allPlayers: [String]) -> [String] {
        var playerCodes = [String : String]()
        for i in 0..<allPlayers.count {
            playerCodes["\(i)"] = allPlayers[i]
        }
        var ret = [String]()
        for char in encoded {
            ret.append(playerCodes[String(char)] ?? "")
        }
        return ret
    }
    
    static private func encodeRoundData(roundData: [Int]) -> String {
        var ret = ""
        for val in roundData {
            ret += "\(val)"
        }
        return ret
    }
    
    static private func decodeRoundData(encoded: String) -> [Int] {
        var ret = [Int]()
        for char in encoded {
            ret.append(Int(String(char)) ?? 0)
        }
        return ret
    }
    
    // red, blue in hex
    static private func encodeColors(redColor: UIColor, blueColor: UIColor) -> String {
        let red = redColor.toHex()!
        let blue = blueColor.toHex()!
        return red + blue
    }
    
    // [red, blue]
    static private func decodeColors(colors: String) -> [UIColor] {
        let redString = String(colors.prefix(6))
        let blueString = String(colors.suffix(6))
        return [UIColor(hex: redString)!, UIColor(hex: blueString)!]
    }
/*
    static func getMatchFromDocument(document: QueryDocumentSnapshot) -> Match {
        let snapshotData = document.data()

        // get match data
        let _playerNamesArray = decodePlayerNames(encoded: snapshotData["playerNamesArray"] as! String)
        let _roundPlayersArray = decodeRoundPlayers(encoded: snapshotData["roundPlayersArray"] as! String, allPlayers: _playerNamesArray)
        let _roundData = decodeRoundData(encoded: snapshotData["roundDataArray"] as! String)
        let _matchID = snapshotData["matchID"] as! Int
        let _startDate = (snapshotData["startDate"] as! Timestamp).dateValue()
        let _endDate = (snapshotData["endDate"] as! Timestamp).dateValue()
        let _colors = decodeColors(colors: snapshotData["colors"] as! String)
        let _redColor = _colors[0]
        let _blueColor = _colors[1]
        let _gameType = snapshotData["gameType"] as! Int
        let _winningScore = snapshotData["winningScore"] as! Int
        let _bustScore = snapshotData["bustScore"] as! Int
        let _roundLimit = snapshotData["roundLimit"] as! Int
        let _firebaseID = document.documentID
        
        return getMatchFromRawData(playerNames: _playerNamesArray, roundPlayers: _roundPlayersArray, roundData: _roundData, id: _matchID, firebaseID: _firebaseID, startDate: _startDate, endDate: _endDate, redColor: _redColor, blueColor: _blueColor, gameType: _gameType, winningScore: _winningScore, bustScore: _bustScore, roundLimit: _roundLimit)
    }
  */
    static private func getMatchesFromDocument(document: QueryDocumentSnapshot) -> [Match] {
        let snapshotData = document.data()
        
        let _bustScores = snapshotData["matchBustScores"] as! [Int]
        let _colors = snapshotData["matchColors"] as! [String]
        let _endDates = snapshotData["matchEndDates"] as! [Timestamp]
        let _gameTypes = snapshotData["matchGameTypes"] as! [Int]
        let _matchIDs = snapshotData["matchMatchIDs"] as! [Int]
        let _playerNamesArrays = snapshotData["matchPlayerNamesArrays"] as! [String]
        let _roundDataArrays = snapshotData["matchRoundDataArrays"] as! [String]
        let _roundLimits = snapshotData["matchRoundLimits"] as! [Int]
        let _roundPlayersArrays = snapshotData["matchRoundPlayersArrays"] as! [String]
        let _startDates = snapshotData["matchStartDates"] as! [Timestamp]
        let _winningScores = snapshotData["matchWinningScores"] as! [Int]
        
        var ret = [Match]()
        
        for i in 0..<_bustScores.count {
            let _bs = _bustScores[i]
            let colors = decodeColors(colors: _colors[i])
            let _rc = colors[0]
            let _bc = colors[1]
            let _ed = _endDates[i].dateValue()
            let _gt = _gameTypes[i]
            let _mid = _matchIDs[i]
            let _pna = decodePlayerNames(encoded: _playerNamesArrays[i])
            let _rda = decodeRoundData(encoded: _roundDataArrays[i])
            let _rl = _roundLimits[i]
            let _rpa = decodeRoundPlayers(encoded: _roundPlayersArrays[i], allPlayers: _pna)
            let _sd = _startDates[i].dateValue()
            let _ws = _winningScores[i]
            ret.append(getMatchFromRawData(playerNames: _pna, roundPlayers: _rpa, roundData: _rda, id: _mid, startDate: _sd, endDate: _ed, redColor: _rc, blueColor: _bc, gameType: _gt, winningScore: _ws, bustScore: _bs, roundLimit: _rl))
        }
        
        return ret
    }
    
    // get league from data
    static func pullLeagues(ids: [String], completion: @escaping ([League]?, Error?) -> Void) {
        var rets = [League]()
        let db = Firestore.firestore()
        
        // get league info
        db.collection("leagues").whereField("id", in: ids).getDocuments { (snapshot, error) in
            if let err = error {
                print("Error getting league info: \(err)")
                completion(nil, err)
            } else {
                if let snapshots = snapshot?.documents {
                    for document in snapshots {
                        
                        let snapshotData = document.data()
                        let ret = League()
                        
                        // basic league info
                        
                        ret.name = snapshotData["name"] as! String
                        ret.ownerID = snapshotData["ownerID"] as! String
                        ret.editorEmails = snapshotData["editorEmails"] as! [String]
                        ret.players = snapshotData["players"] as! [String]
                        ret.firebaseID = snapshotData["id"] as! String
                        ret.firstThrowWinners = snapshotData["firstThrowWinners"] as! Bool
                        ret.gameSettings = GameSettings(
                            gameType: GameType(rawValue: snapshotData["gameType"] as! Int)!,
                            winningScore: snapshotData["winningScore"] as! Int,
                            bustScore: snapshotData["bustScore"] as! Int,
                            roundLimit: snapshotData["roundLimit"] as! Int)
                        
                        // match info
                        
                        ret.matches = getMatchesFromDocument(document: document)
                        
                        // add to total
                        
                        rets.append(ret)
                    }
                    
                    print("pulled one")
                    
                    cachedLeagues.removeAll { ids.contains($0.firebaseID) }
                    cachedLeagues.append(contentsOf: rets)
                    
                    completion(rets, nil)
                }
            }
        }
    }
    
    static func forceNextPull() {
        lastPull = 0
    }
    
    static var lastPull: Double = 0 // number of seconds since epoch when last pull was made
    static var pullTime: Double = 600 // number of seconds between automatic pulls
    
    static func pullAndCacheLeagues(force: Bool, completion: @escaping (Error?, [String]?) -> Void) {
        // only pull leagues if cached leagues is not recent or being forced to pull
        let currentDate = Date.init().timeIntervalSince1970
        print("Time since last pull: \(currentDate - lastPull)")
        if force || currentDate - lastPull > pullTime {
            getLeagues(user: Auth.auth().currentUser!) { (error) in
                var leagueIDs: [String] = UserDefaults.getLeagueIDs()
                if let error = error {
                    completion(error, nil)
                } else {
                    print("pulling all")
                    lastPull = currentDate
                    
                    cachedLeagues.removeAll()
                    if leagueIDs.count == 0 {
                        completion(nil, nil)
                    }
                    
                    // divide ids into groups of 10 for firestore
                    var idsArray = [[String]]()
                    while leagueIDs.count > 0 {
                        let end = min(10, leagueIDs.count)
                        idsArray.append(Array(leagueIDs[0..<end]))
                        leagueIDs = Array(leagueIDs[end...])
                    }
                    print(idsArray)
                    
                    var batchesLeft = idsArray.count
                    var unableIDs = [String]()
                    
                    for ids in idsArray {
                        CornholeFirestore.pullLeagues(ids: ids) { (leagues, error) in
                            if error == nil {
                                for league in leagues! {
                                    if league.name == "" {
                                        leagueIDs.removeAll { $0 == league.firebaseID }
                                        UserDefaults.setLeagueIDs(ids: leagueIDs)
                                        unableIDs.append(league.firebaseID)
                                    }
                                }
                            }
                            batchesLeft -= 1
                            if batchesLeft <= 0 { // done
                                for id in UserDefaults.getLeagueIDs() {
                                    if !cachedLeagues.contains(where: { $0.firebaseID == id }) {
                                        unableIDs.append(id)
                                    }
                                }
                                if unableIDs.count > 0 {
                                    completion(nil, unableIDs)
                                } else {
                                    completion(nil, nil)
                                }
                            }
                        }
                    }
                }
            }
        } else {
            completion(nil, nil)
        }
    }
    
    static func deleteLeague(id: String) {
        
        if UserDefaults.getActiveLeagueID() == id {
            UserDefaults.setActiveLeagueID(id: CornholeFirestore.TEST_LEAGUE_ID)
        }
        
        var savedIDs = UserDefaults.getLeagueIDs()
        savedIDs.removeAll { $0 == id }
        UserDefaults.setLeagueIDs(ids: savedIDs)
        setLeagues(user: Auth.auth().currentUser!)
        
        let db = Firestore.firestore()
        db.collection("leagues").document(id).delete()
        cachedLeagues.removeAll { $0.firebaseID == id }
    }
    
    static func getLeagues(user: User, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { (snapshot, error) in
            if let error = error {
                completion(error)
            } else {
                if let document = snapshot, let data = document.data() {
                    UserDefaults.setLeagueIDs(ids: data["leagues"] as! [String])
                    completion(nil)
                } else {
                    completion(error)
                }
            }
        }
    }
    
    static func setLeagues(user: User) {
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).setData(["leagues": UserDefaults.getLeagueIDs()], merge: true)
    }
    
    static func updateGameSettings(leagueID: String, firstThrowWinners: Bool, settings: GameSettings) {
        let db = Firestore.firestore()
        if let league = getCachedLeague(id: leagueID) {
            league.firstThrowWinners = firstThrowWinners
            league.gameSettings = settings
            db.collection("leagues").document(league.firebaseID).updateData(["firstThrowWinners": firstThrowWinners, "gameType": settings.gameType.rawValue, "winningScore": settings.winningScore, "bustScore": settings.bustScore, "roundLimit": settings.roundLimit])
        }
    }
}

// cache management

func getCachedLeague(id: String) -> League? {
    for league in cachedLeagues {
        if league.firebaseID == id {
            return league
        }
    }
    return nil
}

// messages

func deletedLeagueMessage(ids: [String]) -> String {
    if ids.count == 1 {
        return "Unable to pull league \(ids[0]), it may have been deleted. If you think this is a mistake, note down the ID and try to rejoin."
    } else {
        var strs = ""
        for i in 0..<ids.count - 1 {
            strs += ids[i]
            strs += ", "
        }
        strs += ids[ids.count - 1]
        return "Unable to pull leagues \(strs), they may have been deleted. If you think this is a mistake, note down these IDs and try to rejoin."
    }
}

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
    
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt32 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}

// alert

func createBasicAlert(title: String, message: String) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in
        alert.dismiss(animated: true, completion: nil)
    }))
    
    return alert
}
