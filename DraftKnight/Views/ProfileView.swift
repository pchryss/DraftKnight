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
    var points: Double
    var body: some View {
        HStack {
            if points == -1.0 {
                Text("\(rank). NA")
                    .foregroundColor(.white)
                    .padding(.leading, 20)
                Spacer()
            } else {
                Text("\(rank). \(points, specifier: "%.1f")")
                    .foregroundColor(.white)
                    .padding(.leading, 20)
                Spacer()
                ViewButton()
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
    @State private var topScores: [Double] = Array(repeating: -1, count: 5)
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
                    Game(rank: index + 1, points: topScores[index])
                }
            }

        }
        .onAppear() {
            fetchTop5Games { scores in
                self.topScores = scores
                self.isLoading = false
            }
        }
    }
}

struct ViewButton: View {
    

    var body: some View {
        Button(action: {
            print("hello")
        }) {
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
                .font(.system(size: 20, weight: .bold))

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

func fetchTop5Games(completion: @escaping ([Double]) -> Void) {
    guard let userID = Auth.auth().currentUser?.uid else {
        completion([])
        return
    }
    let db = Firestore.firestore()
    let gamesRef = db.collection("users").document(userID).collection("games")
    gamesRef
        .order(by: "score", descending: true)
        .limit(to: 5)
        .getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching games: \(error.localizedDescription)")
                completion(Array(repeating: -1.0, count: 5))
                return
            }
            guard let documents = snapshot?.documents else {
                completion(Array(repeating: -1.0, count: 5))
                return
            }
            
            var topScores: [Double] = []
            for document in documents {
                if let score = document.data()["score"] as? Double {
                    topScores.append(score)
                }
            }
            while topScores.count < 5 {
                topScores.append(-1.0)
            }
            
            completion(topScores)
        }
}
