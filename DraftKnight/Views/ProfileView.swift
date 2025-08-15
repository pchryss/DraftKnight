//
//  StartView.swift
//  DraftKnight
//
//  Created by Philip Chryssochoos on 6/23/25.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authModel: AuthViewModel

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
                History()
                    .padding(.bottom, 20)
                LogOutButton() {
                    authModel.signOut()
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}

struct Game: View {
    var rank: Int
    var game: GameData
    @State private var showGameDetails = false
    
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
                ViewButton {
                    showGameDetails = true
                }
                .fullScreenCover(isPresented: $showGameDetails) {
                    PrevGameView(gameData: game)
                }
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




struct History: View {
    @State private var topGames: [GameData] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            Text("Your Best Games")
                .foregroundColor(.white)
            
            if isLoading {
                ProgressView("Loading...")
                    .foregroundColor(.white)
                    .padding()
            } else {
                ForEach(0..<5, id: \.self) { index in
                    if index < topGames.count {
                        Game(rank: index + 1, game: topGames[index])
                    } else {
                        Game(rank: index + 1, game: GameData(
                            id: UUID().uuidString,
                            score: -1.0,
                            date: Date(),
                            players: []
                        ))
                    }
                }
            }
        }
        .onAppear {
            fetchTop5Games { games in
                self.topGames = games
                self.isLoading = false
            }
        }
    }
}


struct ViewButton: View {
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
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

struct LogOutButton: View {
    
    let onClick: () -> Void

    var body: some View {
        Button(action: {
            onClick()
        }) {
            Text("Log Out")
                .foregroundColor(.black)
                .font(.system(size: 20, weight: .semibold))

                .frame(width: 150, height: 65)
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

struct GameData: Identifiable {
    var id: String
    var score: Double
    var date: Date
    var players: [PlayerFromDB]
}

func fetchTop5Games(completion: @escaping ([GameData]) -> Void) {
    guard let userID = Auth.auth().currentUser?.uid else {
        completion([])
        return
    }
    
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(userID)
    
    userRef.getDocument { snapshot, error in
        if let error = error {
            print("Error fetching user document: \(error.localizedDescription)")
            completion([])
            return
        }
        
        guard let data = snapshot?.data(),
              let gamesArray = data["games"] as? [[String: Any]] else {
            completion([])
            return
        }
        
        let allGames: [GameData] = gamesArray.compactMap { gameDict in
            guard let score = gameDict["score"] as? Double,
                  let timestamp = gameDict["date"] as? Timestamp else {
                return nil
            }
            
            let playersData = gameDict["players"] as? [[String: Any]] ?? []
            let players: [PlayerFromDB] = playersData.compactMap { dict in
                guard let name = dict["name"] as? String,
                      let team = dict["team"] as? String,
                      let position = dict["position"] as? String,
                      let points = dict["points"] as? Double,
                      let year = dict["year"] as? Int else {
                    return nil
                }
                return PlayerFromDB(id: nil, name: name, team: team, position: position, points: points, year: year)
            }
            
            return GameData(
                id: userID,
                score: score,
                date: timestamp.dateValue(),
                players: players
            )
        }
        
        let top5 = allGames.sorted { $0.score > $1.score }.prefix(5)
        
        completion(Array(top5))
    }
}
