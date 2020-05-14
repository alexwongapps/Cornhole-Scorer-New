//
//  CornholeUITests.swift
//  CornholeUITests
//
//  Created by Alex Wong on 3/6/20.
//  Copyright © 2020 Kids Can Code. All rights reserved.
//

import XCTest

class CornholeUITests: XCTestCase {
    var app: XCUIApplication!
    static let dummyApp = XCUIApplication()
    
    private struct Scoreboard {
        struct Game {
            struct Landscape {
                static var BACKGROUND_IMAGE: XCUIElement = dummyApp
                static var TOTAL_TITLE_LABEL: XCUIElement = dummyApp
                static var TOTAL_RED_LABEL: XCUIElement = dummyApp
                static var TOTAL_DASH_LABEL: XCUIElement = dummyApp
                static var TOTAL_BLUE_LABEL: XCUIElement = dummyApp
                static var SMALL_DEVICE_TOTAL_DASH_LABEL: XCUIElement = dummyApp
                static var ROUND_TITLE_LABEL: XCUIElement = dummyApp
                static var ROUND_RED_LABEL: XCUIElement = dummyApp
                static var ROUND_DASH_LABEL: XCUIElement = dummyApp
                static var ROUND_BLUE_LABEL: XCUIElement = dummyApp
                static var RED_TEAM_LABEL: XCUIElement = dummyApp
                static var BLUE_TEAM_LABEL: XCUIElement = dummyApp
                static var RED_IN_LABEL: XCUIElement = dummyApp
                static var RED_ON_LABEL: XCUIElement = dummyApp
                static var BLUE_IN_LABEL: XCUIElement = dummyApp
                static var BLUE_ON_LABEL: XCUIElement = dummyApp
                static var RED_IN_STEPPER: XCUIElement = dummyApp
                static var RED_ON_STEPPER: XCUIElement = dummyApp
                static var BLUE_IN_STEPPER: XCUIElement = dummyApp
                static var BLUE_ON_STEPPER: XCUIElement = dummyApp
                static var ROUND_COMPLETE_BUTTON: XCUIElement = dummyApp
                static var RESET_BUTTON: XCUIElement = dummyApp
                static var UNDO_BUTTON: XCUIElement = dummyApp
                static var SELECT_NEW_PLAYERS_BUTTON: XCUIElement = dummyApp
            }
            struct Portrait {
                static var BACKGROUND_IMAGE: XCUIElement = dummyApp
                static var TOTAL_TITLE_LABEL: XCUIElement = dummyApp
                static var TOTAL_RED_LABEL: XCUIElement = dummyApp
                static var TOTAL_DASH_LABEL: XCUIElement = dummyApp
                static var TOTAL_BLUE_LABEL: XCUIElement = dummyApp
                static var SMALL_DEVICE_TOTAL_DASH_LABEL: XCUIElement = dummyApp
                static var ROUND_TITLE_LABEL: XCUIElement = dummyApp
                static var ROUND_RED_LABEL: XCUIElement = dummyApp
                static var ROUND_DASH_LABEL: XCUIElement = dummyApp
                static var ROUND_BLUE_LABEL: XCUIElement = dummyApp
                static var RED_TEAM_LABEL: XCUIElement = dummyApp
                static var BLUE_TEAM_LABEL: XCUIElement = dummyApp
                static var RED_IN_LABEL: XCUIElement = dummyApp
                static var RED_ON_LABEL: XCUIElement = dummyApp
                static var BLUE_IN_LABEL: XCUIElement = dummyApp
                static var BLUE_ON_LABEL: XCUIElement = dummyApp
                static var RED_IN_STEPPER: XCUIElement = dummyApp
                static var RED_ON_STEPPER: XCUIElement = dummyApp
                static var BLUE_IN_STEPPER: XCUIElement = dummyApp
                static var BLUE_ON_STEPPER: XCUIElement = dummyApp
                static var ROUND_COMPLETE_BUTTON: XCUIElement = dummyApp
                static var RESET_BUTTON: XCUIElement = dummyApp
                static var UNDO_BUTTON: XCUIElement = dummyApp
                static var SELECT_NEW_PLAYERS_BUTTON: XCUIElement = dummyApp
            }
        }
        struct Login {
            struct Landscape {
                static var BACKGROUND_IMAGE: XCUIElement = dummyApp
                static var TITLE_LABEL: XCUIElement = dummyApp
                static var HELP_BUTTON: XCUIElement = dummyApp
                static var RULES_BUTTON: XCUIElement = dummyApp
                static var NUMBER_OF_PLAYERS_SEGMENTED_CONTROL: XCUIElement = dummyApp
                static var SWAP_COLORS_BUTTON: XCUIElement = dummyApp
                static var ACTIVITY_INDICATOR: XCUIElement = dummyApp
                static var RED_TEAM_LABEL: XCUIElement = dummyApp
                static var RED_CHANGE_COLOR_BUTTON: XCUIElement = dummyApp
                static var RED_PLAYER_1_LABEL: XCUIElement = dummyApp
                static var RED_PLAYER_2_LABEL: XCUIElement = dummyApp
                static var SELECT_RED_PLAYER_1_BUTTON: XCUIElement = dummyApp
                static var SELECT_RED_PLAYER_2_BUTTON: XCUIElement = dummyApp
                static var BLUE_TEAM_LABEL: XCUIElement = dummyApp
                static var BLUE_CHANGE_COLOR_BUTTON: XCUIElement = dummyApp
                static var BLUE_PLAYER_1_LABEL: XCUIElement = dummyApp
                static var BLUE_PLAYER_2_LABEL: XCUIElement = dummyApp
                static var SELECT_BLUE_PLAYER_1_BUTTON: XCUIElement = dummyApp
                static var SELECT_BLUE_PLAYER_2_BUTTON: XCUIElement = dummyApp
                static var CREATE_NEW_PLAYER_LABEL: XCUIElement = dummyApp
                static var NAME_TEXT_FIELD: XCUIElement = dummyApp
                static var ADD_BUTTON: XCUIElement = dummyApp
                static var SELECT_EXISTING_PLAYER_LABEL: XCUIElement = dummyApp
                static var PLAYERS_TABLE: XCUIElement = dummyApp
                static var PLAY_BUTTON: XCUIElement = dummyApp
                static var SMALL_DEVICE_PLAY_BUTTON: XCUIElement = dummyApp
                static var TRACKING_STATS_BUTTON: XCUIElement = dummyApp
            }
            struct Portrait {
                static var BACKGROUND_IMAGE: XCUIElement = dummyApp
                static var TITLE_LABEL: XCUIElement = dummyApp
                static var HELP_BUTTON: XCUIElement = dummyApp
                static var RULES_BUTTON: XCUIElement = dummyApp
                static var NUMBER_OF_PLAYERS_SEGMENTED_CONTROL: XCUIElement = dummyApp
                static var SWAP_COLORS_BUTTON: XCUIElement = dummyApp
                static var ACTIVITY_INDICATOR: XCUIElement = dummyApp
                static var RED_TEAM_LABEL: XCUIElement = dummyApp
                static var RED_CHANGE_COLOR_BUTTON: XCUIElement = dummyApp
                static var RED_PLAYER_1_LABEL: XCUIElement = dummyApp
                static var RED_PLAYER_2_LABEL: XCUIElement = dummyApp
                static var SELECT_RED_PLAYER_1_BUTTON: XCUIElement = dummyApp
                static var SELECT_RED_PLAYER_2_BUTTON: XCUIElement = dummyApp
                static var BLUE_TEAM_LABEL: XCUIElement = dummyApp
                static var BLUE_CHANGE_COLOR_BUTTON: XCUIElement = dummyApp
                static var BLUE_PLAYER_1_LABEL: XCUIElement = dummyApp
                static var BLUE_PLAYER_2_LABEL: XCUIElement = dummyApp
                static var SELECT_BLUE_PLAYER_1_BUTTON: XCUIElement = dummyApp
                static var SELECT_BLUE_PLAYER_2_BUTTON: XCUIElement = dummyApp
                static var CREATE_NEW_PLAYER_LABEL: XCUIElement = dummyApp
                static var NAME_TEXT_FIELD: XCUIElement = dummyApp
                static var ADD_BUTTON: XCUIElement = dummyApp
                static var SELECT_EXISTING_PLAYER_LABEL: XCUIElement = dummyApp
                static var PLAYERS_TABLE: XCUIElement = dummyApp
                static var PLAY_BUTTON: XCUIElement = dummyApp
                static var SMALL_DEVICE_PLAY_BUTTON: XCUIElement = dummyApp
                static var TRACKING_STATS_BUTTON: XCUIElement = dummyApp
            }
        }
        struct SelectColor {
            static var BACKGROUND_IMAGE: XCUIElement = dummyApp
            static var TITLE_LABEL: XCUIElement = dummyApp
            static var PRESETS_COLLECTION: XCUIElement = dummyApp
            static var CREATE_CUSTOM_COLOR_BUTTON: XCUIElement = dummyApp
            static var CUSTOMS_COLLECTION: XCUIElement = dummyApp
        }
        struct CustomColor {
            static var BACKGROUND_IMAGE: XCUIElement = dummyApp
            static var TITLE_LABEL: XCUIElement = dummyApp
            static var RED_LABEL: XCUIElement = dummyApp
            static var GREEN_LABEL: XCUIElement = dummyApp
            static var BLUE_LABEL: XCUIElement = dummyApp
            static var RED_SLIDER: XCUIElement = dummyApp
            static var GREEN_SLIDER: XCUIElement = dummyApp
            static var BLUE_SLIDER: XCUIElement = dummyApp
            static var RED_NUMBER: XCUIElement = dummyApp
            static var GREEN_NUMBER: XCUIElement = dummyApp
            static var BLUE_NUMBER: XCUIElement = dummyApp
            static var COLOR_VIEW: XCUIElement = dummyApp
            static var DONE_BUTTON: XCUIElement = dummyApp
        }
    }
    
    private struct Matches {
        struct List {
            static var BACKGROUND_IMAGE: XCUIElement = dummyApp
            static var TITLE_LABEL: XCUIElement = dummyApp
            static var ACTIVITY_INDICATOR: XCUIElement = dummyApp
            static var REFRESH_BUTTON: XCUIElement = dummyApp
            static var ADD_TO_LEAGUE_BUTTON: XCUIElement = dummyApp
            static var EDIT_BUTTON: XCUIElement = dummyApp
            static var DELETE_BUTTON: XCUIElement = dummyApp
            static var SHARE_BUTTON: XCUIElement = dummyApp
            static var MATCHES_TABLE: XCUIElement = dummyApp
        }
        struct Info {
            static var BACKGROUND_IMAGE: XCUIElement = dummyApp
            static var TITLE_LABEL: XCUIElement = dummyApp
            static var ADD_TO_LEAGUE_BUTTON: XCUIElement = dummyApp
            static var EDIT_PLAYERS_BUTTON: XCUIElement = dummyApp
            static var SHARE_BUTTON: XCUIElement = dummyApp
            static var BACK_BUTTON: XCUIElement = dummyApp
            static var ROUNDS_LABEL: XCUIElement = dummyApp
            static var MATCH_INFO_TABLE: XCUIElement = dummyApp
        }
        struct Settings {
            static var BACKGROUND_IMAGE: XCUIElement = dummyApp
            static var RED_PLAYER_1_LABEL: XCUIElement = dummyApp
            static var RED_PLAYER_1_PICKER: XCUIElement = dummyApp
            static var RED_PLAYER_2_LABEL: XCUIElement = dummyApp
            static var RED_PLAYER_2_PICKER: XCUIElement = dummyApp
            static var BLUE_PLAYER_1_LABEL: XCUIElement = dummyApp
            static var BLUE_PLAYER_1_PICKER: XCUIElement = dummyApp
            static var BLUE_PLAYER_2_LABEL: XCUIElement = dummyApp
            static var BLUE_PLAYER_2_PICKER: XCUIElement = dummyApp
            static var DONE_BUTTON: XCUIElement = dummyApp
        }
    }
    
    private struct Stats {
        struct Main {
            struct Landscape {
                static var BACKGROUND_IMAGE: XCUIElement = dummyApp
                static var TITLE_LABEL: XCUIElement = dummyApp
                static var ACTIVITY_INDICATOR: XCUIElement = dummyApp
                static var STANDINGS_BUTTON: XCUIElement = dummyApp
                static var OPTIONS_BUTTON: XCUIElement = dummyApp
                static var PLAYERS_PICKER: XCUIElement = dummyApp
                static var TIME_PICKER: XCUIElement = dummyApp
                static var MATCH_RECORD_LABEL: XCUIElement = dummyApp
                static var SINGLES_RECORD_LABEL: XCUIElement = dummyApp
                static var DOUBLES_RECORD_LABEL: XCUIElement = dummyApp
                static var ROUND_RECORD_LABEL: XCUIElement = dummyApp
                static var POINTS_PER_ROUND_LABEL: XCUIElement = dummyApp
                static var IN_PER_ROUND_LABEL: XCUIElement = dummyApp
                static var ON_PER_ROUND_LABEL: XCUIElement = dummyApp
                static var OFF_PER_ROUND_LABEL: XCUIElement = dummyApp
                static var PIE_CHART: XCUIElement = dummyApp
                static var BAG_LOCATION_LABEL: XCUIElement = dummyApp
            }
            struct Portrait {
                static var BACKGROUND_IMAGE: XCUIElement = dummyApp
                static var TITLE_LABEL: XCUIElement = dummyApp
                static var ACTIVITY_INDICATOR: XCUIElement = dummyApp
                static var STANDINGS_BUTTON: XCUIElement = dummyApp
                static var OPTIONS_BUTTON: XCUIElement = dummyApp
                static var PLAYERS_PICKER: XCUIElement = dummyApp
                static var TIME_PICKER: XCUIElement = dummyApp
                static var MATCH_RECORD_LABEL: XCUIElement = dummyApp
                static var SINGLES_RECORD_LABEL: XCUIElement = dummyApp
                static var DOUBLES_RECORD_LABEL: XCUIElement = dummyApp
                static var ROUND_RECORD_LABEL: XCUIElement = dummyApp
                static var POINTS_PER_ROUND_LABEL: XCUIElement = dummyApp
                static var IN_PER_ROUND_LABEL: XCUIElement = dummyApp
                static var ON_PER_ROUND_LABEL: XCUIElement = dummyApp
                static var OFF_PER_ROUND_LABEL: XCUIElement = dummyApp
                static var PIE_CHART: XCUIElement = dummyApp
                static var BAG_LOCATION_LABEL: XCUIElement = dummyApp
            }
        }
        struct Standings {
            static var BACKGROUND_IMAGE: XCUIElement = dummyApp
            static var TITLE_LABEL: XCUIElement = dummyApp
            static var BACK_BUTTON: XCUIElement = dummyApp
            static var STANDINGS_TABLE: XCUIElement = dummyApp
        }
    }
    
    private struct Settings {
        struct Main {
            static var BACKGROUND_IMAGE: XCUIElement = dummyApp
            static var TITLE_LABEL: XCUIElement = dummyApp
            static var ACTIVITY_INDICATOR: XCUIElement = dummyApp
            static var GET_PRO_BUTTON: XCUIElement = dummyApp
            static var RESTORE_BUTTON: XCUIElement = dummyApp
            static var LOGIN_BUTTON: XCUIElement = dummyApp
            static var EDIT_LEAGUES_BUTTON: XCUIElement = dummyApp
            static var RESET_MATCHES_BUTTON: XCUIElement = dummyApp
            static var FIRST_TOSSER_LABEL: XCUIElement = dummyApp
            static var FIRST_TOSSER_BUTTON: XCUIElement = dummyApp
            static var EDIT_PLAYER_NAME_BUTTON: XCUIElement = dummyApp
            static var EDIT_PLAYER_NAME_INSTRUCTIONS_LABEL: XCUIElement = dummyApp
            static var EDIT_PLAYER_NAME_TEXT_FIELD: XCUIElement = dummyApp
            static var EDIT_PLAYER_NAME_LEFT_ARROW: XCUIElement = dummyApp
            static var EDIT_PLAYER_NAME_RIGHT_ARROW: XCUIElement = dummyApp
            static var EDIT_PLAYER_NAME_DONE_BUTTON: XCUIElement = dummyApp
            static var GAME_TYPE_LABEL: XCUIElement = dummyApp
            static var GAME_TYPE_BUTTON: XCUIElement = dummyApp
            static var SETTING_1_LABEL: XCUIElement = dummyApp
            static var SETTING_1_STEPPER: XCUIElement = dummyApp
            static var SETTING_2_LABEL: XCUIElement = dummyApp
            static var SETTING_2_STEPPER: XCUIElement = dummyApp
            static var VERSION_LABEL: XCUIElement = dummyApp
            static var FAQ_BUTTON: XCUIElement = dummyApp
            static var DOWN_ARROW: XCUIElement = dummyApp
            static var SCROLL_VIEW: XCUIElement = dummyApp
        }
        struct EditLeagues {
            static var BACKGROUND_IMAGE: XCUIElement = dummyApp
            static var ACTIVITY_INDICATOR: XCUIElement = dummyApp
            static var BACK_BUTTON: XCUIElement = dummyApp
            static var CREATE_BUTTON: XCUIElement = dummyApp
            static var ADD_BUTTON: XCUIElement = dummyApp
            static var REFRESH_BUTTON: XCUIElement = dummyApp
            static var HELP_BUTTON: XCUIElement = dummyApp
            static var LEAGUES_TABLE: XCUIElement = dummyApp
            static var FOLLOW_UNLIMITED_LEAGUES_BUTTON: XCUIElement = dummyApp
        }
        struct LeagueDetail {
            static var BACKGROUND_IMAGE: XCUIElement = dummyApp
            static var ID_LABEL: XCUIElement = dummyApp
            static var ACTIVITY_INDICATOR: XCUIElement = dummyApp
            static var QR_BUTTON: XCUIElement = dummyApp
            static var HELP_BUTTON: XCUIElement = dummyApp
            static var PLAYERS_LABEL: XCUIElement = dummyApp
            static var ADD_PLAYERS_BUTTON: XCUIElement = dummyApp
            static var DELETE_PLAYERS_BUTTON: XCUIElement = dummyApp
            static var PLAYERS_TABLE: XCUIElement = dummyApp
            static var EDITORS_LABEL: XCUIElement = dummyApp
            static var ADD_EDITORS_BUTTON: XCUIElement = dummyApp
            static var DELETE_EDITORS_BUTTON: XCUIElement = dummyApp
            static var EDITORS_TABLE: XCUIElement = dummyApp
            static var DELETE_LEAGUE_BUTTON: XCUIElement = dummyApp
            static var BACK_BUTTON: XCUIElement = dummyApp
        }
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        app = XCUIApplication()
        
        Scoreboard.Game.Landscape.BACKGROUND_IMAGE = app.images["GameBackground"]
        Scoreboard.Game.Landscape.TOTAL_TITLE_LABEL = app.staticTexts["GameTotal"]
        Scoreboard.Game.Landscape.TOTAL_RED_LABEL = app.staticTexts["GameRedTotal"]
        Scoreboard.Game.Landscape.TOTAL_DASH_LABEL = app.staticTexts["GameDashTotal"]
        Scoreboard.Game.Landscape.TOTAL_BLUE_LABEL = app.staticTexts["GameBlueTotal"]
        Scoreboard.Game.Landscape.SMALL_DEVICE_TOTAL_DASH_LABEL = app.staticTexts["GameSEDash"]
        Scoreboard.Game.Landscape.ROUND_TITLE_LABEL = app.staticTexts["GameRound"]
        Scoreboard.Game.Landscape.ROUND_RED_LABEL = app.staticTexts["GameRedRound"]
        Scoreboard.Game.Landscape.ROUND_DASH_LABEL = app.staticTexts["GameDashRound"]
        Scoreboard.Game.Landscape.ROUND_BLUE_LABEL = app.staticTexts["GameBlueRound"]
        Scoreboard.Game.Landscape.RED_TEAM_LABEL = app.staticTexts["GameRedTeam"]
        Scoreboard.Game.Landscape.BLUE_TEAM_LABEL = app.staticTexts["GameBlueTeam"]
        Scoreboard.Game.Landscape.RED_IN_LABEL = app.staticTexts["GameRedIn"]
        Scoreboard.Game.Landscape.RED_ON_LABEL = app.staticTexts["GameRedOn"]
        Scoreboard.Game.Landscape.BLUE_IN_LABEL = app.staticTexts["GameBlueIn"]
        Scoreboard.Game.Landscape.BLUE_ON_LABEL = app.staticTexts["GameBlueOn"]
        Scoreboard.Game.Landscape.RED_IN_STEPPER = app.steppers["GameRedInStepper"]
        Scoreboard.Game.Landscape.RED_ON_STEPPER = app.steppers["GameRedOnStepper"]
        Scoreboard.Game.Landscape.BLUE_IN_STEPPER = app.steppers["GameBlueInStepper"]
        Scoreboard.Game.Landscape.BLUE_ON_STEPPER = app.steppers["GameBlueOnStepper"]
        Scoreboard.Game.Landscape.ROUND_COMPLETE_BUTTON = app.buttons["GameRoundComplete"]
        Scoreboard.Game.Landscape.RESET_BUTTON = app.buttons["GameReset"]
        Scoreboard.Game.Landscape.UNDO_BUTTON = app.buttons["GameUndo"]
        Scoreboard.Game.Landscape.SELECT_NEW_PLAYERS_BUTTON = app.buttons["GameSelectNew"]
        
        Scoreboard.Game.Portrait.BACKGROUND_IMAGE = app.images["GameBackgroundP"]
        Scoreboard.Game.Portrait.TOTAL_TITLE_LABEL = app.staticTexts["GameTotalP"]
        Scoreboard.Game.Portrait.TOTAL_RED_LABEL = app.staticTexts["GameRedTotalP"]
        Scoreboard.Game.Portrait.TOTAL_DASH_LABEL = app.staticTexts["GameDashTotalP"]
        Scoreboard.Game.Portrait.TOTAL_BLUE_LABEL = app.staticTexts["GameBlueTotalP"]
        Scoreboard.Game.Portrait.SMALL_DEVICE_TOTAL_DASH_LABEL = app.staticTexts["GameSEDashP"]
        Scoreboard.Game.Portrait.ROUND_TITLE_LABEL = app.staticTexts["GameRoundP"]
        Scoreboard.Game.Portrait.ROUND_RED_LABEL = app.staticTexts["GameRedRoundP"]
        Scoreboard.Game.Portrait.ROUND_DASH_LABEL = app.staticTexts["GameDashRoundP"]
        Scoreboard.Game.Portrait.ROUND_BLUE_LABEL = app.staticTexts["GameBlueRoundP"]
        Scoreboard.Game.Portrait.RED_TEAM_LABEL = app.staticTexts["GameRedTeamP"]
        Scoreboard.Game.Portrait.BLUE_TEAM_LABEL = app.staticTexts["GameBlueTeamP"]
        Scoreboard.Game.Portrait.RED_IN_LABEL = app.staticTexts["GameRedInP"]
        Scoreboard.Game.Portrait.RED_ON_LABEL = app.staticTexts["GameRedOnP"]
        Scoreboard.Game.Portrait.BLUE_IN_LABEL = app.staticTexts["GameBlueInP"]
        Scoreboard.Game.Portrait.BLUE_ON_LABEL = app.staticTexts["GameBlueOnP"]
        Scoreboard.Game.Portrait.RED_IN_STEPPER = app.steppers["GameRedInStepperP"]
        Scoreboard.Game.Portrait.RED_ON_STEPPER = app.steppers["GameRedOnStepperP"]
        Scoreboard.Game.Portrait.BLUE_IN_STEPPER = app.steppers["GameBlueInStepperP"]
        Scoreboard.Game.Portrait.BLUE_ON_STEPPER = app.steppers["GameBlueOnStepperP"]
        Scoreboard.Game.Portrait.ROUND_COMPLETE_BUTTON = app.buttons["GameRoundCompleteP"]
        Scoreboard.Game.Portrait.RESET_BUTTON = app.buttons["GameResetP"]
        Scoreboard.Game.Portrait.UNDO_BUTTON = app.buttons["GameUndoP"]
        Scoreboard.Game.Portrait.SELECT_NEW_PLAYERS_BUTTON = app.buttons["GameSelectNewP"]
        
        Scoreboard.Login.Landscape.BACKGROUND_IMAGE = app.images["LoginBackground"]
        Scoreboard.Login.Landscape.TITLE_LABEL = app.staticTexts["LoginTitle"]
        Scoreboard.Login.Landscape.HELP_BUTTON = app.buttons["LoginHelp"]
        Scoreboard.Login.Landscape.RULES_BUTTON = app.buttons["LoginRules"]
        Scoreboard.Login.Landscape.NUMBER_OF_PLAYERS_SEGMENTED_CONTROL = app.segmentedControls["LoginNumberOfPlayers"]
        Scoreboard.Login.Landscape.SWAP_COLORS_BUTTON = app.buttons["LoginSwap"]
        Scoreboard.Login.Landscape.ACTIVITY_INDICATOR = app.activityIndicators["LoginActivity"]
        Scoreboard.Login.Landscape.RED_TEAM_LABEL = app.staticTexts["LoginRed"]
        Scoreboard.Login.Landscape.RED_CHANGE_COLOR_BUTTON = app.buttons["LoginRedChange"]
        Scoreboard.Login.Landscape.RED_PLAYER_1_LABEL = app.staticTexts["LoginRed1"]
        Scoreboard.Login.Landscape.SELECT_RED_PLAYER_1_BUTTON = app.buttons["LoginSelectRed1"]
        Scoreboard.Login.Landscape.RED_PLAYER_2_LABEL = app.staticTexts["LoginRed2"]
        Scoreboard.Login.Landscape.SELECT_RED_PLAYER_2_BUTTON = app.buttons["LoginSelectRed2"]
        Scoreboard.Login.Landscape.BLUE_TEAM_LABEL = app.staticTexts["LoginBlue"]
        Scoreboard.Login.Landscape.BLUE_CHANGE_COLOR_BUTTON = app.buttons["LoginBlueChange"]
        Scoreboard.Login.Landscape.BLUE_PLAYER_1_LABEL = app.staticTexts["LoginBlue1"]
        Scoreboard.Login.Landscape.SELECT_BLUE_PLAYER_1_BUTTON = app.buttons["LoginSelectBlue1"]
        Scoreboard.Login.Landscape.BLUE_PLAYER_2_LABEL = app.staticTexts["LoginBlue2"]
        Scoreboard.Login.Landscape.SELECT_BLUE_PLAYER_2_BUTTON = app.buttons["LoginSelectBlue2"]
        Scoreboard.Login.Landscape.CREATE_NEW_PLAYER_LABEL = app.staticTexts["LoginCreate"]
        Scoreboard.Login.Landscape.NAME_TEXT_FIELD = app.textFields["LoginNewPlayerName"]
        Scoreboard.Login.Landscape.ADD_BUTTON = app.buttons["LoginAdd"]
        Scoreboard.Login.Landscape.SELECT_EXISTING_PLAYER_LABEL = app.staticTexts["LoginSelectExisting"]
        Scoreboard.Login.Landscape.PLAYERS_TABLE = app.tables["LoginTable"]
        Scoreboard.Login.Landscape.PLAY_BUTTON = app.buttons["LoginPlay"]
        Scoreboard.Login.Landscape.SMALL_DEVICE_PLAY_BUTTON = app.buttons["LoginSEPlay"]
        Scoreboard.Login.Landscape.TRACKING_STATS_BUTTON = app.buttons["LoginTracking"]
        
        Scoreboard.Login.Portrait.BACKGROUND_IMAGE = app.images["LoginBackgroundP"]
        Scoreboard.Login.Portrait.TITLE_LABEL = app.staticTexts["LoginTitleP"]
        Scoreboard.Login.Portrait.HELP_BUTTON = app.buttons["LoginHelpP"]
        Scoreboard.Login.Portrait.RULES_BUTTON = app.buttons["LoginRulesP"]
        Scoreboard.Login.Portrait.NUMBER_OF_PLAYERS_SEGMENTED_CONTROL = app.segmentedControls["LoginNumberOfPlayersP"]
        Scoreboard.Login.Portrait.SWAP_COLORS_BUTTON = app.buttons["LoginSwapP"]
        Scoreboard.Login.Portrait.ACTIVITY_INDICATOR = app.activityIndicators["LoginActivityP"]
        Scoreboard.Login.Portrait.RED_TEAM_LABEL = app.staticTexts["LoginRedP"]
        Scoreboard.Login.Portrait.RED_CHANGE_COLOR_BUTTON = app.buttons["LoginRedChangeP"]
        Scoreboard.Login.Portrait.RED_PLAYER_1_LABEL = app.staticTexts["LoginRed1P"]
        Scoreboard.Login.Portrait.SELECT_RED_PLAYER_1_BUTTON = app.buttons["LoginSelectRed1P"]
        Scoreboard.Login.Portrait.RED_PLAYER_2_LABEL = app.staticTexts["LoginRed2P"]
        Scoreboard.Login.Portrait.SELECT_RED_PLAYER_2_BUTTON = app.buttons["LoginSelectRed2P"]
        Scoreboard.Login.Portrait.BLUE_TEAM_LABEL = app.staticTexts["LoginBlueP"]
        Scoreboard.Login.Portrait.BLUE_CHANGE_COLOR_BUTTON = app.buttons["LoginBlueChangeP"]
        Scoreboard.Login.Portrait.BLUE_PLAYER_1_LABEL = app.staticTexts["LoginBlue1P"]
        Scoreboard.Login.Portrait.SELECT_BLUE_PLAYER_1_BUTTON = app.buttons["LoginSelectBlue1P"]
        Scoreboard.Login.Portrait.BLUE_PLAYER_2_LABEL = app.staticTexts["LoginBlue2P"]
        Scoreboard.Login.Portrait.SELECT_BLUE_PLAYER_2_BUTTON = app.buttons["LoginSelectBlue2P"]
        Scoreboard.Login.Portrait.CREATE_NEW_PLAYER_LABEL = app.staticTexts["LoginCreateP"]
        Scoreboard.Login.Portrait.NAME_TEXT_FIELD = app.textFields["LoginNewPlayerNameP"]
        Scoreboard.Login.Portrait.ADD_BUTTON = app.buttons["LoginAddP"]
        Scoreboard.Login.Portrait.SELECT_EXISTING_PLAYER_LABEL = app.staticTexts["LoginSelectExistingP"]
        Scoreboard.Login.Portrait.PLAYERS_TABLE = app.tables["LoginTableP"]
        Scoreboard.Login.Portrait.PLAY_BUTTON = app.buttons["LoginPlayP"]
        Scoreboard.Login.Portrait.SMALL_DEVICE_PLAY_BUTTON = app.buttons["LoginSEPlayP"]
        Scoreboard.Login.Portrait.TRACKING_STATS_BUTTON = app.buttons["LoginTrackingP"]
        
        Scoreboard.SelectColor.BACKGROUND_IMAGE = app.images["SCBackground"]
        Scoreboard.SelectColor.TITLE_LABEL = app.staticTexts["SCTitle"]
        Scoreboard.SelectColor.PRESETS_COLLECTION = app.collectionViews["SCPresets"]
        Scoreboard.SelectColor.CREATE_CUSTOM_COLOR_BUTTON = app.buttons["SCCreate"]
        Scoreboard.SelectColor.CUSTOMS_COLLECTION = app.collectionViews["SCCustoms"]
        
        Scoreboard.CustomColor.BACKGROUND_IMAGE = app.images["CCBackground"]
        Scoreboard.CustomColor.TITLE_LABEL = app.staticTexts["CCTitle"]
        Scoreboard.CustomColor.RED_LABEL = app.staticTexts["CCRLabel"]
        Scoreboard.CustomColor.GREEN_LABEL = app.staticTexts["CCGLabel"]
        Scoreboard.CustomColor.BLUE_LABEL = app.staticTexts["CCBLabel"]
        Scoreboard.CustomColor.RED_SLIDER = app.sliders["CCRSlider"]
        Scoreboard.CustomColor.GREEN_SLIDER = app.sliders["CCGSlider"]
        Scoreboard.CustomColor.BLUE_SLIDER = app.sliders["CCBSlider"]
        Scoreboard.CustomColor.RED_NUMBER = app.staticTexts["CCRNumber"]
        Scoreboard.CustomColor.GREEN_NUMBER = app.staticTexts["CCGNumber"]
        Scoreboard.CustomColor.BLUE_NUMBER = app.staticTexts["CCBNumber"]
        Scoreboard.CustomColor.COLOR_VIEW = app.otherElements["CCColorView"]
        Scoreboard.CustomColor.DONE_BUTTON = app.buttons["CCDone"]
        
        Matches.List.BACKGROUND_IMAGE = app.images["ListBackground"]
        Matches.List.TITLE_LABEL = app.staticTexts["ListTitle"]
        Matches.List.ACTIVITY_INDICATOR = app.activityIndicators["ListActivity"]
        Matches.List.REFRESH_BUTTON = app.buttons["ListRefresh"]
        Matches.List.ADD_TO_LEAGUE_BUTTON = app.buttons["ListAdd"]
        Matches.List.EDIT_BUTTON = app.buttons["ListEdit"]
        Matches.List.DELETE_BUTTON = app.buttons["ListDelete"]
        Matches.List.SHARE_BUTTON = app.buttons["ListShare"]
        Matches.List.MATCHES_TABLE = app.tables["ListTable"]
        
        Matches.Info.BACKGROUND_IMAGE = app.images["InfoBackground"]
        Matches.Info.TITLE_LABEL = app.staticTexts["InfoTitle"]
        Matches.Info.ADD_TO_LEAGUE_BUTTON = app.buttons["InfoAdd"]
        Matches.Info.EDIT_PLAYERS_BUTTON = app.buttons["InfoEdit"]
        Matches.Info.SHARE_BUTTON = app.buttons["InfoShare"]
        Matches.Info.BACK_BUTTON = app.buttons["InfoBack"]
        Matches.Info.ROUNDS_LABEL = app.staticTexts["InfoRounds"]
        Matches.Info.MATCH_INFO_TABLE = app.tables["InfoTable"]
        
        Matches.Settings.BACKGROUND_IMAGE = app.images["SettingsBackground"]
        Matches.Settings.RED_PLAYER_1_LABEL = app.staticTexts["SettingsRed1"]
        Matches.Settings.RED_PLAYER_1_PICKER = app.pickerWheels.element(boundBy: 0)
        Matches.Settings.RED_PLAYER_2_LABEL = app.staticTexts["SettingsRed2"]
        Matches.Settings.RED_PLAYER_2_PICKER = app.pickerWheels.element(boundBy: 2)
        Matches.Settings.BLUE_PLAYER_1_LABEL = app.staticTexts["SettingsBlue1"]
        Matches.Settings.BLUE_PLAYER_1_PICKER = app.pickerWheels.element(boundBy: 1)
        Matches.Settings.BLUE_PLAYER_2_LABEL = app.staticTexts["SettingsBlue2"]
        Matches.Settings.BLUE_PLAYER_2_PICKER = app.pickerWheels.element(boundBy: 3)
        Matches.Settings.DONE_BUTTON = app.buttons["SettingsDone"]
        
        Stats.Main.Landscape.BACKGROUND_IMAGE = app.images["StatsBackground"]
        Stats.Main.Landscape.TITLE_LABEL = app.staticTexts["StatsTitle"]
        Stats.Main.Landscape.ACTIVITY_INDICATOR = app.activityIndicators["StatsActivity"]
        Stats.Main.Landscape.STANDINGS_BUTTON = app.buttons["StatsStandings"]
        Stats.Main.Landscape.OPTIONS_BUTTON = app.buttons["StatsOptions"]
        Stats.Main.Landscape.PLAYERS_PICKER = app.pickerWheels.element(boundBy: 0)
        Stats.Main.Landscape.TIME_PICKER = app.pickerWheels.element(boundBy: 1)
        Stats.Main.Landscape.MATCH_RECORD_LABEL = app.staticTexts["StatsMRecord"]
        Stats.Main.Landscape.SINGLES_RECORD_LABEL = app.staticTexts["StatsSRecord"]
        Stats.Main.Landscape.DOUBLES_RECORD_LABEL = app.staticTexts["StatsDRecord"]
        Stats.Main.Landscape.ROUND_RECORD_LABEL = app.staticTexts["StatsRRecord"]
        Stats.Main.Landscape.POINTS_PER_ROUND_LABEL = app.staticTexts["StatsPointsPR"]
        Stats.Main.Landscape.IN_PER_ROUND_LABEL = app.staticTexts["StatsInPR"]
        Stats.Main.Landscape.ON_PER_ROUND_LABEL = app.staticTexts["StatsOnPR"]
        Stats.Main.Landscape.OFF_PER_ROUND_LABEL = app.staticTexts["StatsOffPR"]
        Stats.Main.Landscape.PIE_CHART = app.otherElements["StatsPie"]
        Stats.Main.Landscape.BAG_LOCATION_LABEL = app.staticTexts["StatsBL"]
        
        Stats.Main.Portrait.BACKGROUND_IMAGE = app.images["StatsBackgroundP"]
        Stats.Main.Portrait.TITLE_LABEL = app.staticTexts["StatsTitleP"]
        Stats.Main.Portrait.ACTIVITY_INDICATOR = app.activityIndicators["StatsActivityP"]
        Stats.Main.Portrait.STANDINGS_BUTTON = app.buttons["StatsStandingsP"]
        Stats.Main.Portrait.OPTIONS_BUTTON = app.buttons["StatsOptionsP"]
        Stats.Main.Portrait.PLAYERS_PICKER = app.pickerWheels.element(boundBy: 0)
        Stats.Main.Portrait.TIME_PICKER = app.pickerWheels.element(boundBy: 1)
        Stats.Main.Portrait.MATCH_RECORD_LABEL = app.staticTexts["StatsMRecordP"]
        Stats.Main.Portrait.SINGLES_RECORD_LABEL = app.staticTexts["StatsSRecordP"]
        Stats.Main.Portrait.DOUBLES_RECORD_LABEL = app.staticTexts["StatsDRecordP"]
        Stats.Main.Portrait.ROUND_RECORD_LABEL = app.staticTexts["StatsRRecordP"]
        Stats.Main.Portrait.POINTS_PER_ROUND_LABEL = app.staticTexts["StatsPointsPRP"]
        Stats.Main.Portrait.IN_PER_ROUND_LABEL = app.staticTexts["StatsInPRP"]
        Stats.Main.Portrait.ON_PER_ROUND_LABEL = app.staticTexts["StatsOnPRP"]
        Stats.Main.Portrait.OFF_PER_ROUND_LABEL = app.staticTexts["StatsOffPRP"]
        Stats.Main.Portrait.PIE_CHART = app.otherElements["StatsPieP"]
        Stats.Main.Portrait.BAG_LOCATION_LABEL = app.staticTexts["StatsBLP"]
        
        Stats.Standings.BACKGROUND_IMAGE = app.images["StandingsBackground"]
        Stats.Standings.TITLE_LABEL = app.staticTexts["StandingsTitle"]
        Stats.Standings.BACK_BUTTON = app.buttons["StandingsBack"]
        Stats.Standings.STANDINGS_TABLE = app.tables["StandingsTable"]
        
        Settings.Main.BACKGROUND_IMAGE = app.images["SetTabBackground"]
        Settings.Main.TITLE_LABEL = app.staticTexts["SetTabTitle"]
        Settings.Main.ACTIVITY_INDICATOR = app.activityIndicators["SetTabActivity"]
        Settings.Main.GET_PRO_BUTTON = app.buttons["SetTabPro"]
        Settings.Main.RESTORE_BUTTON = app.buttons["SetTabRestore"]
        Settings.Main.LOGIN_BUTTON = app.buttons["SetTabLogin"]
        Settings.Main.EDIT_LEAGUES_BUTTON = app.buttons["SetTabEditLeagues"]
        Settings.Main.RESET_MATCHES_BUTTON = app.buttons["SetTabReset"]
        Settings.Main.FIRST_TOSSER_LABEL = app.staticTexts["SetTabFT"]
        Settings.Main.FIRST_TOSSER_BUTTON = app.buttons["SetTabFTButton"]
        Settings.Main.EDIT_PLAYER_NAME_BUTTON = app.buttons["SetTabEPN"]
        Settings.Main.EDIT_PLAYER_NAME_INSTRUCTIONS_LABEL = app.staticTexts["SetTabEPNInstructions"]
        Settings.Main.EDIT_PLAYER_NAME_TEXT_FIELD = app.textFields["SetTabEPNField"]
        Settings.Main.EDIT_PLAYER_NAME_LEFT_ARROW = app.buttons["SetTabEPNLeft"]
        Settings.Main.EDIT_PLAYER_NAME_RIGHT_ARROW = app.buttons["SetTabEPNRight"]
        Settings.Main.EDIT_PLAYER_NAME_DONE_BUTTON = app.buttons["SetTabEPNDone"]
        Settings.Main.GAME_TYPE_LABEL = app.staticTexts["SetTabType"]
        Settings.Main.GAME_TYPE_BUTTON = app.buttons["SetTabTypeButton"]
        Settings.Main.SETTING_1_LABEL = app.staticTexts["SetTabS1"]
        Settings.Main.SETTING_1_STEPPER = app.steppers["SetTabS1Stepper"]
        Settings.Main.SETTING_2_LABEL = app.staticTexts["SetTabS2"]
        Settings.Main.SETTING_2_STEPPER = app.steppers["SetTabS2Stepper"]
        Settings.Main.VERSION_LABEL = app.staticTexts["SetTabVersion"]
        Settings.Main.FAQ_BUTTON = app.buttons["SetTabFAQ"]
        Settings.Main.DOWN_ARROW = app.staticTexts["SetTabDown"]
        Settings.Main.SCROLL_VIEW = app.scrollViews["SetTabScroll"]
        
        Settings.EditLeagues.BACKGROUND_IMAGE = app.images["ELBackground"]
        Settings.EditLeagues.ACTIVITY_INDICATOR = app.activityIndicators["ELActivity"]
        Settings.EditLeagues.BACK_BUTTON = app.buttons["ELBack"]
        Settings.EditLeagues.CREATE_BUTTON = app.buttons["ELCreate"]
        Settings.EditLeagues.ADD_BUTTON = app.buttons["ELAdd"]
        Settings.EditLeagues.REFRESH_BUTTON = app.buttons["ELRefresh"]
        Settings.EditLeagues.HELP_BUTTON = app.buttons["ELHelp"]
        Settings.EditLeagues.LEAGUES_TABLE = app.tables["ELTable"]
        Settings.EditLeagues.FOLLOW_UNLIMITED_LEAGUES_BUTTON = app.buttons["ELUnlimited"]
        
        Settings.LeagueDetail.BACKGROUND_IMAGE = app.images["LDBackground"]
        Settings.LeagueDetail.ID_LABEL = app.staticTexts["LDID"]
        Settings.LeagueDetail.ACTIVITY_INDICATOR = app.activityIndicators["LDActivity"]
        Settings.LeagueDetail.QR_BUTTON = app.buttons["LDQR"]
        Settings.LeagueDetail.HELP_BUTTON = app.buttons["LDHelp"]
        Settings.LeagueDetail.PLAYERS_LABEL = app.staticTexts["LDPlayers"]
        Settings.LeagueDetail.ADD_PLAYERS_BUTTON = app.buttons["LDAddPlayers"]
        Settings.LeagueDetail.DELETE_PLAYERS_BUTTON = app.buttons["LDDeletePlayers"]
        Settings.LeagueDetail.PLAYERS_TABLE = app.tables["LDPlayersTable"]
        Settings.LeagueDetail.EDITORS_LABEL = app.staticTexts["LDEditors"]
        Settings.LeagueDetail.ADD_EDITORS_BUTTON = app.buttons["LDAddEditors"]
        Settings.LeagueDetail.DELETE_EDITORS_BUTTON = app.buttons["LDDeleteEditors"]
        Settings.LeagueDetail.EDITORS_TABLE = app.tables["LDEditorsTable"]
        Settings.LeagueDetail.DELETE_LEAGUE_BUTTON = app.buttons["LDDeleteLeague"]
        Settings.LeagueDetail.BACK_BUTTON = app.navigationBars.buttons["LDBack"]

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        app.launchArguments.append("--uitesting")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testOpenApp() {
        app.launch()
    }

    func testBasicGame() {
        // UI tests must launch the application that they test.
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        playMatch(red1: "Alex", red2: "Bob", blue1: "Carol", blue2: "Danny",
                 rounds: [[1, 3, 2, 2],
                          [0, 0, 4, 0],
                          [1, 0, 3, 1]])
    }
    
    func testCreateColor() {
        
        app.launch()
        
        Scoreboard.Login.Portrait.RED_CHANGE_COLOR_BUTTON.tap()
        Scoreboard.SelectColor.CREATE_CUSTOM_COLOR_BUTTON.tap()
        Scoreboard.CustomColor.RED_SLIDER.adjust(toNormalizedSliderPosition: 0.7)
        Scoreboard.CustomColor.BLUE_SLIDER.adjust(toNormalizedSliderPosition: 0.6)
        Scoreboard.CustomColor.GREEN_SLIDER.adjust(toNormalizedSliderPosition: 0.5)
        Scoreboard.CustomColor.DONE_BUTTON.tap()
        Scoreboard.SelectColor.CUSTOMS_COLLECTION.cells.element(boundBy: 0).tap()
    }
    
    func testViewMatch() {
        
        app.launch()
        
        playMatch(red1: "Alex", blue1: "Deb", rounds: [[4, 0, 0, 0], [3, 0, 0, 0]])
        app.tabBars.buttons["Matches"].tap()
        Matches.List.MATCHES_TABLE.cells.element(boundBy: 0).tap()
        Matches.Info.BACK_BUTTON.tap()
    }
    
    func testEditPlayers() {
        
        app.launch()
        
        playMatch(red1: "Alex", blue1: "Deb", rounds: [[4, 0, 0, 0], [3, 0, 0, 0]])
        app.tabBars.buttons["Matches"].tap()
        Matches.List.MATCHES_TABLE.cells.element(boundBy: 0).tap()
        Matches.Info.EDIT_PLAYERS_BUTTON.tap()
        Matches.Settings.RED_PLAYER_1_PICKER.adjust(toPickerWheelValue: "Deb")
        Matches.Settings.BLUE_PLAYER_1_PICKER.adjust(toPickerWheelValue: "Alex")
        Matches.Settings.DONE_BUTTON.tap()
    }
    
    func testViewStats() {
        
        app.launch()
        
        playMatch(red1: "Alex", blue1: "Deb", rounds: [[4, 0, 0, 0], [3, 0, 0, 0]])
        app.tabBars.buttons["Stats"].tap()
        Stats.Main.Portrait.PLAYERS_PICKER.adjust(toPickerWheelValue: "Deb")
        Stats.Main.Portrait.TIME_PICKER.adjust(toPickerWheelValue: "Last 7 Days")
    }
    
    func testEditSettings() {
        
        app.launch()
        
        app.tabBars.buttons["Settings"].tap()
        Settings.Main.SETTING_1_STEPPER.buttons.allElementsBoundByIndex[1].tap()
        Settings.Main.SETTING_1_STEPPER.buttons.allElementsBoundByIndex[0].tap()
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func playMatch(red1: String, red2: String? = nil, blue1: String, blue2: String? = nil, rounds: [[Int]]) {
        login(red1: red1, red2: red2, blue1: blue1, blue2: blue2)
        for round in rounds {
            playRound(redIn: round[0], redOn: round[1], blueIn: round[2], blueOn: round[3])
        }
    }
    
    // requires start on login screen and all player names don't already exist
    func login(red1: String, red2: String?, blue1: String, blue2: String?) {
        Scoreboard.Login.Portrait.SELECT_RED_PLAYER_1_BUTTON.tap()
        Scoreboard.Login.Portrait.NAME_TEXT_FIELD.tap()
        Scoreboard.Login.Portrait.NAME_TEXT_FIELD.typeText(red1)
        Scoreboard.Login.Portrait.ADD_BUTTON.tap()
        Scoreboard.Login.Portrait.SELECT_BLUE_PLAYER_1_BUTTON.tap()
        Scoreboard.Login.Portrait.NAME_TEXT_FIELD.tap()
        Scoreboard.Login.Portrait.NAME_TEXT_FIELD.typeText(blue1)
        Scoreboard.Login.Portrait.ADD_BUTTON.tap()
        if red2 != nil {
            Scoreboard.Login.Portrait.NUMBER_OF_PLAYERS_SEGMENTED_CONTROL.buttons["2 v 2"].tap()
            Scoreboard.Login.Portrait.SELECT_RED_PLAYER_2_BUTTON.tap()
            Scoreboard.Login.Portrait.NAME_TEXT_FIELD.tap()
            Scoreboard.Login.Portrait.NAME_TEXT_FIELD.typeText(red2!)
            Scoreboard.Login.Portrait.ADD_BUTTON.tap()
            Scoreboard.Login.Portrait.SELECT_BLUE_PLAYER_2_BUTTON.tap()
            Scoreboard.Login.Portrait.NAME_TEXT_FIELD.tap()
            Scoreboard.Login.Portrait.NAME_TEXT_FIELD.typeText(blue2!)
            Scoreboard.Login.Portrait.ADD_BUTTON.tap()
        }
        Scoreboard.Login.Portrait.PLAY_BUTTON.tap()
    }
    
    func playRound(redIn: Int, redOn: Int, blueIn: Int, blueOn: Int) {
        for _ in 0..<redIn {
            Scoreboard.Game.Portrait.RED_IN_STEPPER.buttons.allElementsBoundByIndex[1].tap()
        }
        for _ in 0..<redOn {
            Scoreboard.Game.Portrait.RED_ON_STEPPER.buttons.allElementsBoundByIndex[1].tap()
        }
        for _ in 0..<blueIn {
            Scoreboard.Game.Portrait.BLUE_IN_STEPPER.buttons.allElementsBoundByIndex[1].tap()
        }
        for _ in 0..<blueOn {
            Scoreboard.Game.Portrait.BLUE_ON_STEPPER.buttons.allElementsBoundByIndex[1].tap()
        }
        Scoreboard.Game.Portrait.ROUND_COMPLETE_BUTTON.tap()
    }
    
    func rotate(orientation: UIDeviceOrientation) {
        XCUIDevice.shared.orientation = orientation
    }
}
