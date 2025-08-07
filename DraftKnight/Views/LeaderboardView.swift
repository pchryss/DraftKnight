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

struct Leaderboard: View {
    @State private var topScores: [Double] = Array(repeating: -1, count: 10)
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
                    Game(rank: index + 1, points: topScores[index])
                }
            }

        }
        .onAppear() {
            fetchTop10Games { scores in
                self.topScores = scores
                self.isLoading = false
            }
        }
    }
}

func fetchTop10Games(completion: @escaping ([Double]) -> Void) {
    guard let userID = Auth.auth().currentUser?.uid else {
        completion([])
        return
    }
    let db = Firestore.firestore()
    let gamesRef = db.collection("users").document(userID).collection("games")
    gamesRef
        .order(by: "score", descending: true)
        .limit(to: 10)
        .getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching games: \(error.localizedDescription)")
                completion(Array(repeating: -1.0, count: 10))
                return
            }
            guard let documents = snapshot?.documents else {
                completion(Array(repeating: -1.0, count: 10))
                return
            }
            
            var topScores: [Double] = []
            for document in documents {
                if let score = document.data()["score"] as? Double {
                    topScores.append(score)
                }
            }
            while topScores.count < 10 {
                topScores.append(-1.0)
            }
            
            completion(topScores)
        }
}
