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
let COLORS = [
    UIColor.red: "Red",
    UIColor.blue: "Blue"
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
            let blueColorRGBA = matchInfo["blueColorRGBA"] as? [CGFloat]/*,
            let gameType = matchInfo["gameType"] as? Int,
            let winningScore = matchInfo["winningScore"] as? Int,
            let bustScore = matchInfo["bustScore"] as? Int,
            let roundLimit = matchInfo["roundLimit"] as? Int*/ else {
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
    var id: Int = 0
    var players: [String] = []
    var matches: [Match] = []
    var ownerID: String = ""
    var editorEmails: [String] = []
    var firebaseID: String = ""
    
    static let NEW_ID_FAILED = -1
    
    init() {
    }
    
    init(name: String, owner: User) {
        self.name = name
        self.id = League.NEW_ID_FAILED // placeholder if fails
        self.ownerID = owner.uid
        self.editorEmails = [owner.email!]
    }
    
    func getNewID(completion: @escaping (Error?) -> Void) {
        CornholeFirestore.readField(collection: "universal", document: "constants", field: "nextLeagueID") { (id, error) in
            if let newID = id as? Int {
                self.id = newID
                CornholeFirestore.updateField(collection: "universal", document: "constants", field: "nextLeagueID", value: newID + 1)
                completion(nil)
            } else if let error = error {
                completion(error)
            }
        }
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

func getMatchFromRawData(playerNames: [String], roundPlayers: [String], roundData: [Int], id: Int, startDate: Date, endDate: Date, redColor: UIColor, blueColor: UIColor, gameType: Int, winningScore: Int, bustScore: Int, roundLimit: Int) -> Match {
    
    var thisMatchRounds: [Round] = []
    
    for roundNum in 0...((roundData.count / 6) - 1) { // gets a round #
        thisMatchRounds.append(Round(red: Board(bagsIn: roundData[roundNum * 6], bagsOn: roundData[roundNum * 6 + 1], bagsOff: roundData[roundNum * 6 + 2]), blue: Board(bagsIn: roundData[roundNum * 6 + 3], bagsOn: roundData[roundNum * 6 + 4], bagsOff: roundData[roundNum * 6 + 5]), redPlayer: roundPlayers[roundNum * 2], bluePlayer: roundPlayers[roundNum * 2 + 1]))
    }
    
    // get game type
    let actualGameType: GameType = GameType(rawValue: gameType) ?? GameType.standard
    
    let gameSettings = GameSettings(gameType: actualGameType, winningScore: winningScore, bustScore: bustScore, roundLimit: roundLimit)
    
    if playerNames.count == 2 {
        return Match(redPlayers: [playerNames[0]], bluePlayers: [playerNames[1]], rounds: thisMatchRounds, id: id, start: startDate, end: endDate, redColor: redColor, blueColor: blueColor, gameSettings: gameSettings)
    } else {
        return Match(redPlayers: [playerNames[0], playerNames[1]], bluePlayers: [playerNames[2], playerNames[3]], rounds: thisMatchRounds, id: id, start: startDate, end: endDate, redColor: redColor, blueColor: blueColor, gameSettings: gameSettings)
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

class GameSettings {
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
}

// defaults

extension UserDefaults {
    static func getLeagueIDs() -> [Int] {
        let defaults = UserDefaults.standard
        return defaults.array(forKey: "leagueIDs") as? [Int] ?? []
    }

    static func setLeagueIDs(ids: [Int]) {
        let defaults = UserDefaults.standard
        defaults.set(ids, forKey: "leagueIDs")
    }
    
    static func getActiveLeagueID() -> Int {
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: "activeLeagueID")
    }
    
    static func setActiveLeagueID(id: Int) {
        let defaults = UserDefaults.standard
        defaults.set(id, forKey: "activeLeagueID")
    }
    
    // pull from cached leagues
    static func getActiveLeague() -> League? {
        return getCachedLeague(id: getActiveLeagueID())
    }
}

// firebase

class CornholeFirestore {
    
    static let TEST_LEAGUE_ID: Int = -56

    static func readField(collection: String, document: String, field: String, completion: @escaping (Any?, Error?) -> Void) {
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

    static func updateField(collection: String, document: String, field: String, value: Any) {
        let db = Firestore.firestore()
        db.collection(collection).document(document).updateData([field: value])
    }
    
    static func createLeague(league: League) {
        let db = Firestore.firestore()
        cachedLeagues.append(league)
        db.collection("leagues").addDocument(data: ["name": league.name, "id": league.id, "ownerID": league.ownerID, "editorEmails": league.editorEmails])
    }
    
    static func addEditorToLeague(leagueID: Int, editorEmail: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        // todo: cache league document and do this w/o completion?
        if let league = getCachedLeague(id: leagueID) {
            league.editorEmails.append(editorEmail)
        }
        db.collection("leagues").whereField("id", isEqualTo: leagueID).getDocuments { (snapshot, error) in
            if let err = error {
                print("error adding editor: \(err)")
                completion(err)
            } else {
                for document in snapshot!.documents {
                    document.reference.updateData(["editorEmails": FieldValue.arrayUnion([editorEmail])])
                }
                completion(nil)
            }
        }
    }
    
    static func deleteEditorFromLeague(leagueID: Int, editorEmail: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        // todo: cache league document and do this w/o completion?
        db.collection("leagues").whereField("id", isEqualTo: leagueID).getDocuments { (snapshot, error) in
            if let err = error {
                print("error deleting editor: \(err)")
                completion(err)
            } else {
                if let league = getCachedLeague(id: leagueID) {
                    league.editorEmails.removeAll { $0 == editorEmail }
                }
                for document in snapshot!.documents {
                    document.reference.updateData(["editorEmails": FieldValue.arrayRemove([editorEmail])])
                }
                completion(nil)
            }
        }
    }
    
    static func addPlayerToLeague(leagueID: Int, playerName: String) {
        let db = Firestore.firestore()
        if let league = getCachedLeague(id: leagueID) {
            league.players.append(playerName)
        }
        db.collection("players").addDocument(data: ["name": playerName, "leagueID": leagueID])
    }
    
    static func deletePlayerFromLeague(leagueID: Int, playerName: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("players").whereField("leagueID", isEqualTo: leagueID).whereField("name", isEqualTo: playerName).getDocuments { (snapshot, error) in
            if let err = error {
                print("error deleting player: \(err)")
                completion(err)
            } else {
                if let league = getCachedLeague(id: leagueID) {
                    league.players.removeAll { $0 == playerName }
                }
                for document in snapshot!.documents {
                    document.reference.delete()
                }
                completion(nil)
            }
        }
    }
    
    static func addMatchToLeague(leagueID: Int, match: Match) {
        let db = Firestore.firestore()
        if let league = getCachedLeague(id: leagueID) {
            league.matches.append(match)
        }
        var ref: DocumentReference? = nil
        ref = db.collection("matches").addDocument(data: getDataFromMatch(leagueID: leagueID, match: match)) { err in
            if let err = err {
                print("error adding match: \(err)")
            }
        }
        // set match id with auto-generated id
        updateField(collection: "matches", document: ref!.documentID, field: "matchID", value: match.id)
    }
    
    static func deleteMatchFromLeague(leagueID: Int, matchID: Int, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("matches").whereField("leagueID", isEqualTo: leagueID).whereField("matchID", isEqualTo: matchID).getDocuments { (snapshot, error) in
            if let err = error {
                print("error deleting match: \(err)")
                completion(err)
            } else {
                if let league = getCachedLeague(id: leagueID) {
                    league.matches.removeAll { $0.id == matchID }
                }
                for document in snapshot!.documents {
                    document.reference.delete()
                }
                completion(nil)
            }
        }
    }
    
    static func getDataFromMatch(leagueID: Int, match: Match) -> [String: Any] {
        var ret: [String : Any] = [:]
        ret["leagueID"] = leagueID
        ret["playerNamesArray"] = match.redPlayers + match.bluePlayers
        ret["roundPlayersArray"] = match.getRoundPlayers()
        ret["roundDataArray"] = match.getRoundData()
        ret["matchID"] = match.id
        ret["redColor"] = [match.redColor.rgba.red, match.redColor.rgba.green, match.redColor.rgba.blue, match.redColor.rgba.alpha]
        ret["blueColor"] = [match.blueColor.rgba.red, match.blueColor.rgba.green, match.blueColor.rgba.blue, match.blueColor.rgba.alpha]
        ret["startDate"] = Timestamp.init(date: match.startDate)
        ret["endDate"] = Timestamp.init(date: match.endDate)
        ret["gameType"] = match.gameSettings.gameType.rawValue
        ret["winningScore"] = match.gameSettings.winningScore
        ret["bustScore"] = match.gameSettings.bustScore
        ret["roundLimit"] = match.gameSettings.roundLimit
        return ret
    }
    
    // get league from data
    static func pullLeague(id: Int, completion: @escaping (League?, Error?) -> Void) {
        let ret = League()
        
        var doneState = 0 {
            didSet {
                if doneState == 3 { // info, matches, players
                    cachedLeagues.append(ret)
                    completion(ret, nil)
                }
            }
        }
        let db = Firestore.firestore()
        
        // get league info
        db.collection("leagues").whereField("id", isEqualTo: id).getDocuments { (snapshot, error) in
            if let err = error {
                print("Error getting league info: \(err)")
                completion(nil, err)
            } else {
                for document in snapshot!.documents {
                    let snapshotData = document.data()
                    ret.name = snapshotData["name"] as! String
                    ret.id = snapshotData["id"] as! Int
                    ret.ownerID = snapshotData["ownerID"] as! String
                    ret.editorEmails = snapshotData["editorEmails"] as! [String]
                    ret.firebaseID = document.documentID
                }
                doneState += 1
            }
        }
        
        // get matches
        db.collection("matches").whereField("leagueID", isEqualTo: id).getDocuments() { (snapshot, error) in
            if let err = error {
                print("Error getting matches: \(err)")
                completion(nil, err)
            } else {
                for document in snapshot!.documents {
                    let snapshotData = document.data()
                    
                    // get match data
                    let _playerNamesArray = snapshotData["playerNamesArray"] as! [String]
                    let _roundPlayersArray = snapshotData["roundPlayersArray"] as! [String]
                    let _roundData = snapshotData["roundDataArray"] as! [Int]
                    let _matchID = snapshotData["matchID"] as! Int
                    let _startDate = (snapshotData["startDate"] as! Timestamp).dateValue()
                    let _endDate = (snapshotData["endDate"] as! Timestamp).dateValue()
                    let _redColor = UIColor.init(red: (snapshotData["redColor"] as! [CGFloat])[0], green: (snapshotData["redColor"] as! [CGFloat])[1], blue: (snapshotData["redColor"] as! [CGFloat])[2], alpha: (snapshotData["redColor"] as! [CGFloat])[3])
                    let _blueColor = UIColor.init(red: (snapshotData["blueColor"] as! [CGFloat])[0], green: (snapshotData["blueColor"] as! [CGFloat])[1], blue: (snapshotData["blueColor"] as! [CGFloat])[2], alpha: (snapshotData["blueColor"] as! [CGFloat])[3])
                    let _gameType = snapshotData["gameType"] as! Int
                    let _winningScore = snapshotData["winningScore"] as! Int
                    let _bustScore = snapshotData["bustScore"] as! Int
                    let _roundLimit = snapshotData["roundLimit"] as! Int
                    
                    ret.matches.append(getMatchFromRawData(playerNames: _playerNamesArray, roundPlayers: _roundPlayersArray, roundData: _roundData, id: _matchID, startDate: _startDate, endDate: _endDate, redColor: _redColor, blueColor: _blueColor, gameType: _gameType, winningScore: _winningScore, bustScore: _bustScore, roundLimit: _roundLimit))
                }
                
                doneState += 1
            }
        }
        
        // get players
        db.collection("players").whereField("leagueID", isEqualTo: id).getDocuments { (snapshot, error) in
            if let err = error {
                print("Error getting players: \(err)")
                completion(nil, err)
            } else {
                for document in snapshot!.documents {
                    let snapshotData = document.data()
                    
                    // get player data
                    let name = snapshotData["name"] as! String
                    
                    ret.players.append(name)
                }
                
                doneState += 1
            }
        }
    }
    
    static func pullAndCacheLeagues(completion: @escaping (String?) -> Void) {
        var leagueIDs: [Int] = UserDefaults.getLeagueIDs()
        var leaguesLeft = leagueIDs.count
        var unableIDs: [Int] = []
        cachedLeagues.removeAll()
        for id in leagueIDs {
            CornholeFirestore.pullLeague(id: id) { (league, error) in
                if error != nil {
                    unableIDs.append(id)
                } else if league!.name == "" {
                    leagueIDs.removeAll { $0 == id }
                    UserDefaults.setLeagueIDs(ids: leagueIDs)
                    unableIDs.append(id)
                }
                leaguesLeft -= 1
                if leaguesLeft <= 0 { // done
                    if unableIDs.count > 0 {
                        var message = "Unable to print these IDs: "
                        for i in 0..<unableIDs.count - 1 {
                            message += "\(unableIDs[i]), "
                        }
                        message += "\(unableIDs[unableIDs.count - 1])"
                        completion(message)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
}

// cache management

func getCachedLeague(id: Int) -> League? {
    for league in cachedLeagues {
        if league.id == id {
            return league
        }
    }
    return nil
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
}

// alert

func createBasicAlert(title: String, message: String) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in
        alert.dismiss(animated: true, completion: nil)
    }))
    
    return alert
}
