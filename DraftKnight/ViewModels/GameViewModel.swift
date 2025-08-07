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
    var teams: [String: Team] = [
        "ARI": Team(name: "Arizona Cardinals", logoPath: "cardinals", backgroundColor: Color(red: 151/255, green: 35/255, blue: 63/255), db: "ARI"),
        "ATL": Team(name: "Atlanta Falcons", logoPath: "falcons", backgroundColor: Color(red: 167/255, green: 25/255, blue: 48/255), db: "ATL"),
        "BAL": Team(name: "Baltimore Ravens", logoPath: "ravens", backgroundColor: Color(red: 26/255, green: 25/255, blue: 95/255), db: "BAL"),
        "BUF": Team(name: "Buffalo Bills", logoPath: "bills", backgroundColor: Color(red: 0/255, green: 51/255, blue: 141/255), db: "BUF"),
        "CAR": Team(name: "Carolina Panthers", logoPath: "panthers", backgroundColor: Color(red: 0/255, green: 133/255, blue: 202/255), db: "CAR"),
        "CHI": Team(name: "Chicago Bears", logoPath: "bears", backgroundColor: Color(red: 11/255, green: 22/255, blue: 42/255), db: "CHI"),
        "CIN": Team(name: "Cincinnati Bengals", logoPath: "bengals", backgroundColor: Color(red: 251/255, green: 79/255, blue: 20/255), db: "CIN"),
        "CLE": Team(name: "Cleveland Browns", logoPath: "browns", backgroundColor: Color(red: 255/255, green: 60/255, blue: 0/255), db: "CLE"),
        "DAL": Team(name: "Dallas Cowboys", logoPath: "cowboys", backgroundColor: Color(red: 0/255, green: 34/255, blue: 68/255), db: "DAL"),
        "DEN": Team(name: "Denver Broncos", logoPath: "broncos", backgroundColor: Color(red: 251/255, green: 79/255, blue: 20/255), db: "DEN"),
        "DET": Team(name: "Detroit Lions", logoPath: "lions", backgroundColor: Color(red: 0/255, green: 118/255, blue: 182/255), db: "DET"),
        "GB": Team(name: "Green Bay Packers", logoPath: "packers", backgroundColor: Color(red: 24/255, green: 48/255, blue: 40/255), db: "GB"),
        "HOU": Team(name: "Houston Texans", logoPath: "texans", backgroundColor: Color(red: 3/255, green: 32/255, blue: 47/255), db: "HOU"),
        "IND": Team(name: "Indianapolis Colts", logoPath: "colts", backgroundColor: Color(red: 0/255, green: 44/255, blue: 95/255), db: "IND"),
        "JAX": Team(name: "Jacksonville Jaguars", logoPath: "jaguars", backgroundColor: Color(red: 0/255, green: 103/255, blue: 120/255), db: "JAX"),
        "KC": Team(name: "Kansas City Chiefs", logoPath: "chiefs", backgroundColor: Color(red: 227/255, green: 24/255, blue: 55/255), db: "KC"),
        "LV": Team(name: "Las Vegas Raiders", logoPath: "raiders", backgroundColor: Color(red: 0/255, green: 0/255, blue: 0/255), db: "LV"),
        "LAC": Team(name: "Los Angeles Chargers", logoPath: "chargers", backgroundColor: Color(red: 0/255, green: 128/255, blue: 198/255), db: "LAC"),
        "LAR": Team(name: "Los Angeles Rams", logoPath: "rams", backgroundColor: Color(red: 0/255, green: 53/255, blue: 148/255), db: "LAR"),
        "MIA": Team(name: "Miami Dolphins", logoPath: "dolphins", backgroundColor: Color(red: 0/255, green: 142/255, blue: 151/255), db: "MIA"),
        "MIN": Team(name: "Minnesota Vikings", logoPath: "vikings", backgroundColor: Color(red: 79/255, green: 38/255, blue: 131/255), db: "MIN"),
        "NE": Team(name: "New England Patriots", logoPath: "patriots", backgroundColor: Color(red: 0/255, green: 34/255, blue: 68/255), db: "NE"),
        "NO": Team(name: "New Orleans Saints", logoPath: "saints", backgroundColor: Color(red: 211/255, green: 188/255, blue: 141/255), db: "NO"),
        "NYG": Team(name: "New York Giants", logoPath: "giants", backgroundColor: Color(red: 1/255, green: 35/255, blue: 82/255), db: "NYG"),
        "NYJ": Team(name: "New York Jets", logoPath: "jets", backgroundColor: Color(red: 18/255, green: 87/255, blue: 64/255), db: "NYJ"),
        "PHI": Team(name: "Philadelphia Eagles", logoPath: "eagles", backgroundColor: Color(red: 0/255, green: 76/255, blue: 84/255), db: "PHI"),
        "PIT": Team(name: "Pittsburgh Steelers", logoPath: "steelers", backgroundColor: Color(red: 255/255, green: 182/255, blue: 18/255), db: "PIT"),
        "SF": Team(name: "San Francisco 49ers", logoPath: "49ers", backgroundColor: Color(red: 170/255, green: 0/255, blue: 0/255), db: "SF"),
        "SEA": Team(name: "Seattle Seahawks", logoPath: "seahawks", backgroundColor: Color(red: 0/255, green: 34/255, blue: 68/255), db: "SEA"),
        "TB": Team(name: "Tampa Bay Buccaneers", logoPath: "buccaneers", backgroundColor: Color(red: 213/255, green: 10/255, blue: 10/255), db: "TB"),
        "TEN": Team(name: "Tennessee Titans", logoPath: "titans", backgroundColor: Color(red: 12/255, green: 35/255, blue: 64/255), db: "TEN"),
        "WAS": Team(name: "Washington Commanders", logoPath: "commanders", backgroundColor: Color(red: 90/255, green: 20/255, blue: 20/255), db: "WAS")
    ]
    func randomizeTeam() async {
        for _ in 1...10 {
            selectedTeam = teams.values.randomElement()
            try? await Task.sleep(nanoseconds: 100_000_000)

        }
    }
    func fetchPlayers(team: String, position: String) {
        let baseQuery = db.collection("teams").document(team).collection("players")
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


