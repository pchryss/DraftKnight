//
//  CounterViewModel.swift
//  DraftKnight
//
//  Created by Philip Chryssochoos on 6/23/25.
//
import Foundation
import Combine
import SwiftUI
import Foundation
import FirebaseFirestore
// create a class of the same name by convention
// ObservableObject tells the UI to re-render the view if anything changes

class GameViewModel: ObservableObject {
    // flags the variable. If it changes, the view is re-rendered
    
    @Published var selectedTeam: Team? = nil
    @Published var players: [PlayerFromDB] = []
    private var db = Firestore.firestore()
    var teams: [Team] = [
        Team(name: "New York Jets", logoPath: "Jets", backgroundColor: Color(red: 18/255, green: 87/255, blue: 64/255), db: "NYJ"),
        Team(name: "New England Patriots", logoPath: "Patriots", backgroundColor: Color(red: 0/255, green: 34/255, blue: 68/255), db: "NE"),
        Team(name: "Buffalo Bills", logoPath: "Bills", backgroundColor: Color(red: 0/255, green: 51/255, blue: 141/255), db: "BUF"),
        Team(name: "Miami Dolphins", logoPath: "Dolphins", backgroundColor: Color(red: 0/255, green: 142/255, blue: 151/255), db: "MIA")
    ]
    func randomizeTeam() async {
        for _ in 1...5 {
            selectedTeam = teams[Int.random(in: 0..<teams.count)]
            try? await Task.sleep(nanoseconds: 250_000_000)

        }
    }
    func fetchPlayers(team: String, position: String) {
        let baseQuery = db.collection("teams").document(team).collection("players")  // ✅ top-level collection
        if position != "FLEX" {
            
            baseQuery
                .whereField("position", isEqualTo: position)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Firestore error: \(error.localizedDescription)")
                        return
                    }

                    guard let docs = snapshot?.documents else {
                        print("No documents found (snapshot was nil)")
                        return
                    }


                    let decoded = docs.compactMap { doc -> PlayerFromDB? in
                        do {
                            return try doc.data(as: PlayerFromDB.self)
                        } catch {
                            print("Decoding failed for doc \(doc.documentID): \(error)")
                            return nil
                        }
                    }

                    DispatchQueue.main.async {
                        self.players = decoded
                    }
                }
        } else {
            // FLEX: RB, WR, TE combined
            let positions = ["RB", "WR", "TE"]
            let group = DispatchGroup()
            var flexPlayers: [PlayerFromDB] = []

            for pos in positions {
                group.enter()
                baseQuery
                    .whereField("position", isEqualTo: pos)
                    .getDocuments { snapshot, error in
                        if let docs = snapshot?.documents {
                            let decoded = docs.compactMap { try? $0.data(as: PlayerFromDB.self) }
                            flexPlayers.append(contentsOf: decoded)
                        }
                        group.leave()
                    }
            }

            group.notify(queue: .main) {
                self.players = flexPlayers
            }
        }
    }
    func filteredPlayers(searchText: String) -> [PlayerFromDB] {
        if searchText.isEmpty {
            return players
        } else {
            return players.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}


