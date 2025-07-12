//
//  PlayerFromDB.swift
//  DraftKnight
//
//  Created by Philip Chryssochoos on 7/10/25.
//
import FirebaseFirestore

struct PlayerFromDB: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var name: String
    var team: String
    var position: String
    var points: Double
    var year: Int
}
