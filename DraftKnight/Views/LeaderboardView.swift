//
//  LeaderboardView.swift
//  DraftKnight
//
//  Created by Philip Chryssochoos on 8/3/25.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct LeaderboardView: View {

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(edges: .all)
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(#colorLiteral(red: 0.07058823853731155, green: 0.07058823853731155, blue: 0.07450980693101883, alpha: 1)), location: 0),
                    .init(color: Color(#colorLiteral(red: 0.10196078568696976, green: 0.10196078568696976, blue: 0.11372549086809158, alpha: 1)), location: 0.7195587754249573),
                    .init(color: Color(#colorLiteral(red: 0.08235294371843338, green: 0.08235294371843338, blue: 0.08235294371843338, alpha: 1)), location: 1)]),
                startPoint: UnitPoint(x: 1.1131840781819538, y: 0.034324952532510944),
                endPoint: UnitPoint(x: -0.08582107197307076, y: 0.9084668511127786)
            )
            .ignoresSafeArea()
            
            VStack {
                Leaderboard()
            }
        }
    }
}

#Preview {
    LeaderboardView()
}

struct LeaderboardEntry: Identifiable {
    var id: String
    var userID: String
    var score: Double
    var timestamp: Date
    var players: [PlayerFromDB]
}

struct LeaderboardViewButton: View {
    
    var gameData: LeaderboardEntry

    var body: some View {
        NavigationLink(destination: PrevGameView()) {
            Text("View ")
                .foregroundColor(.black)
                .font(.system(size: 20))

                .frame(width: 70, height: 30)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0xC7 / 255, green: 0xEE / 255, blue: 0xFF / 255),   // #C7EEFF
                            Color(red: 0x4D / 255, green: 0x6D / 255, blue: 0xE3 / 255)  // #4D6DE3
                        ]),
                        startPoint: UnitPoint(x: -2.5, y: -2.5),
                        endPoint: UnitPoint(x: 2.5, y: 2.5)
                    )
                )
                .cornerRadius(30)
        }
    }
}

struct LeaderboardGame: View {
    var rank: Int
    var game: LeaderboardEntry
    
    var body: some View {
        HStack {
            if game.score == -1.0 {
                Text("\(rank). NA")
                    .foregroundColor(.white)
                    .padding(.leading, 20)
                Spacer()
            } else {
                Text("\(rank). \(game.score, specifier: "%.1f")")
                    .foregroundColor(.white)
                    .padding(.leading, 20)
                Spacer()
                LeaderboardViewButton(gameData: game)
                    .padding(.trailing, 20)
            }
        }
        .frame(maxWidth: 250, maxHeight: 50)
        .background(Color.white.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct Leaderboard: View {
    @State private var topScores: [LeaderboardEntry] = Array(repeating:
        LeaderboardEntry(id: UUID().uuidString, userID: "-1", score: -1.0, timestamp: Date(), players: []),
        count: 10
    )
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            Text("Weekly Global Top 10")
                .foregroundColor(.white)
            
            if isLoading {
                ProgressView("Loading...")
                    .foregroundColor(.white)
                    .padding()
            } else {
                ForEach(0..<10, id: \.self) { index in
                    if index < topScores.count {
                        LeaderboardGame(rank: index + 1, game: topScores[index])
                    } else {
                        LeaderboardGame(rank: index + 1, game: LeaderboardEntry(
                            id: UUID().uuidString,
                            userID: "-1",
                            score: -1.0,
                            timestamp: Date(),
                            players: []
                        ))
                    }
                }
            }
        }
        .onAppear {
            fetchWeeklyTop10Games { scores in
                self.topScores = scores
                self.isLoading = false
            }
        }
    }
}


func fetchWeeklyTop10Games(completion: @escaping ([LeaderboardEntry]) -> Void) {
    let db = Firestore.firestore()
    let weekID = getCurrentWeekID()
    let topScoresRef = db.collection("weekly_leaderboards")
                         .document(weekID)
                         .collection("topScores")
    
    topScoresRef
        .order(by: "score", descending: true)
        .limit(to: 10)
        .getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching weekly leaderboard: \(error.localizedDescription)")
                completion(Array(repeating:
                    LeaderboardEntry(id: UUID().uuidString, userID: "-1", score: -1.0, timestamp: Date(), players: []),
                    count: 10
                ))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(Array(repeating:
                    LeaderboardEntry(id: UUID().uuidString, userID: "-1", score: -1.0, timestamp: Date(), players: []),
                    count: 10
                ))
                return
            }
            
            var topScores: [LeaderboardEntry] = []
            
            for document in documents {
                let data = document.data()
                
                guard let userID = data["userId"] as? String,
                      let score = data["score"] as? Double,
                      let timestamp = data["timestamp"] as? Timestamp else {
                    continue
                }
                
                let playersData = data["players"] as? [[String: Any]] ?? []
                
                let players = playersData.compactMap { dict -> PlayerFromDB? in
                    guard let name = dict["name"] as? String,
                          let team = dict["team"] as? String,
                          let position = dict["position"] as? String,
                          let points = dict["points"] as? Double,
                          let year = dict["year"] as? Int else {
                        return nil
                    }
                    return PlayerFromDB(id: nil, name: name, team: team, position: position, points: points, year: year)
                }
                
                topScores.append(LeaderboardEntry(
                    id: document.documentID,
                    userID: userID,
                    score: score,
                    timestamp: timestamp.dateValue(),
                    players: players
                ))
            }
            
            while topScores.count < 10 {
                topScores.append(LeaderboardEntry(
                    id: UUID().uuidString,
                    userID: "-1",
                    score: -1.0,
                    timestamp: Date(),
                    players: []
                ))
            }
            
            completion(topScores)
        }
}


func getCurrentWeekID() -> String {
    var calendar = Calendar(identifier: .iso8601)
    calendar.timeZone = TimeZone(abbreviation: "UTC")!
    let date = Date()
    let year = calendar.component(.yearForWeekOfYear, from: date)
    let weekOfYear = calendar.component(.weekOfYear, from: date)

    return String(format: "%d-W%02d", year, weekOfYear)
}


