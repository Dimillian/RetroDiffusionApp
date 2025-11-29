//
//  Models.swift
//  RetroDiffusionApp
//
//  Created by Thomas Ricouard on 29/11/25.
//

import Foundation

enum RetroDiffusionModel: String, CaseIterable, Identifiable {
    case rdProDefault = "rd_pro__default"
    case rdProPainterly = "rd_pro__painterly"
    case rdProFantasy = "rd_pro__fantasy"
    case rdProHorror = "rd_pro__horror"
    case rdProScifi = "rd_pro__scifi"
    case rdProSimple = "rd_pro__simple"
    case rdProIsometric = "rd_pro__isometric"
    case rdProTopdown = "rd_pro__topdown"
    case rdProPlatformer = "rd_pro__platformer"
    case rdProDungeonMap = "rd_pro__dungeon_map"
    case rdProSpritesheet = "rd_pro__spritesheet"
    case rdProPixelate = "rd_pro__pixelate"

    case rdFastDefault = "rd_fast__default"
    case rdFastRetro = "rd_fast__retro"
    case rdFastSimple = "rd_fast__simple"
    case rdFastDetailed = "rd_fast__detailed"
    case rdFastAnime = "rd_fast__anime"
    case rdFastGameAsset = "rd_fast__game_asset"
    case rdFastPortrait = "rd_fast__portrait"
    case rdFastTexture = "rd_fast__texture"
    case rdFastUI = "rd_fast__ui"
    case rdFastItemSheet = "rd_fast__item_sheet"
    case rdFastCharacterTurnaround = "rd_fast__character_turnaround"
    case rdFast1Bit = "rd_fast__1_bit"
    case rdFastLowRes = "rd_fast__low_res"
    case rdFastMcItem = "rd_fast__mc_item"
    case rdFastMcTexture = "rd_fast__mc_texture"
    case rdFastNoStyle = "rd_fast__no_style"

    case rdPlusDefault = "rd_plus__default"
    case rdPlusRetro = "rd_plus__retro"
    case rdPlusWatercolor = "rd_plus__watercolor"
    case rdPlusTextured = "rd_plus__textured"
    case rdPlusCartoon = "rd_plus__cartoon"
    case rdPlusUIElement = "rd_plus__ui_element"
    case rdPlusItemSheet = "rd_plus__item_sheet"
    case rdPlusCharacterTurnaround = "rd_plus__character_turnaround"
    case rdPlusEnvironment = "rd_plus__environment"
    case rdPlusTopdownMap = "rd_plus__topdown_map"
    case rdPlusTopdownAsset = "rd_plus__topdown_asset"
    case rdPlusIsometric = "rd_plus__isometric"
    case rdPlusIsometricAsset = "rd_plus__isometric_asset"
    case rdPlusClassic = "rd_plus__classic"
    case rdPlusLowRes = "rd_plus__low_res"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .rdProDefault: return "RD Pro - Default"
        case .rdProPainterly: return "RD Pro - Painterly"
        case .rdProFantasy: return "RD Pro - Fantasy"
        case .rdProHorror: return "RD Pro - Horror"
        case .rdProScifi: return "RD Pro - Sci-Fi"
        case .rdProSimple: return "RD Pro - Simple"
        case .rdProIsometric: return "RD Pro - Isometric"
        case .rdProTopdown: return "RD Pro - Top Down"
        case .rdProPlatformer: return "RD Pro - Platformer"
        case .rdProDungeonMap: return "RD Pro - Dungeon Map"
        case .rdProSpritesheet: return "RD Pro - Spritesheet"
        case .rdProPixelate: return "RD Pro - Pixelate"
        case .rdFastDefault: return "RD Fast - Default"
        case .rdFastRetro: return "RD Fast - Retro"
        case .rdFastSimple: return "RD Fast - Simple"
        case .rdFastDetailed: return "RD Fast - Detailed"
        case .rdFastAnime: return "RD Fast - Anime"
        case .rdFastGameAsset: return "RD Fast - Game Asset"
        case .rdFastPortrait: return "RD Fast - Portrait"
        case .rdFastTexture: return "RD Fast - Texture"
        case .rdFastUI: return "RD Fast - UI"
        case .rdFastItemSheet: return "RD Fast - Item Sheet"
        case .rdFastCharacterTurnaround: return "RD Fast - Character Turnaround"
        case .rdFast1Bit: return "RD Fast - 1 Bit"
        case .rdFastLowRes: return "RD Fast - Low Res"
        case .rdFastMcItem: return "RD Fast - MC Item"
        case .rdFastMcTexture: return "RD Fast - MC Texture"
        case .rdFastNoStyle: return "RD Fast - No Style"
        case .rdPlusDefault: return "RD Plus - Default"
        case .rdPlusRetro: return "RD Plus - Retro"
        case .rdPlusWatercolor: return "RD Plus - Watercolor"
        case .rdPlusTextured: return "RD Plus - Textured"
        case .rdPlusCartoon: return "RD Plus - Cartoon"
        case .rdPlusUIElement: return "RD Plus - UI Element"
        case .rdPlusItemSheet: return "RD Plus - Item Sheet"
        case .rdPlusCharacterTurnaround: return "RD Plus - Character Turnaround"
        case .rdPlusEnvironment: return "RD Plus - Environment"
        case .rdPlusTopdownMap: return "RD Plus - Top Down Map"
        case .rdPlusTopdownAsset: return "RD Plus - Top Down Asset"
        case .rdPlusIsometric: return "RD Plus - Isometric"
        case .rdPlusIsometricAsset: return "RD Plus - Isometric Asset"
        case .rdPlusClassic: return "RD Plus - Classic"
        case .rdPlusLowRes: return "RD Plus - Low Res"
        }
    }
}

struct InferenceRequest: Codable {
    let width: Int
    let height: Int
    let prompt: String
    let numImages: Int
    let promptStyle: String?
    let inputImage: String?
    let checkCost: Bool?

    enum CodingKeys: String, CodingKey {
        case width, height, prompt
        case numImages = "num_images"
        case promptStyle = "prompt_style"
        case inputImage = "input_image"
        case checkCost = "check_cost"
    }
}

struct InferenceResponse: Codable {
    let createdAt: Int
    let creditCost: Int
    let base64Images: [String]
    let type: String?
    let remainingCredits: Int?
    let balanceCost: Double?

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case creditCost = "credit_cost"
        case base64Images = "base64_images"
        case type
        case remainingCredits = "remaining_credits"
        case balanceCost = "balance_cost"
    }
}

struct CreditsResponse: Codable {
    let credits: Int
}
