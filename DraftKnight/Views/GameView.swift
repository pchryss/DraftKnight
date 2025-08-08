//
//  GameView.swift
//  DraftKnight
//
//  Created by Philip Chryssochoos on 6/25/25.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// Views are almost always defined using structs instead of classes
//      They are lightweight, and be recreated easily, and have value semantics (for diffing)
//
// : View says ContentView conforms to the View protool
//      A view is anything that can be displayed on screen
//      Requires us to provide a body property that defines the view layout



struct GameView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var model: GameViewModel
    @State var activePosition: String? = nil
    @State var activePlayer: Binding<PlayerFromDB?>?

    @State var canSelect: Bool = false
    @State var score: Double = 0
    @State var selectedPlayers: [PlayerFromDB?] = [nil, nil, nil, nil, nil, nil, nil]

    var isOptionOneEnabled: Bool = false
    var onPlayAgain: () -> Void
    var onGoToLobby: () -> Void
    @State var isPlaying: Bool = true
    @State var playersPicked = 0
    @State private var resetTrigger = UUID()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea(edges: .all)
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(#colorLiteral(red: 0.0705, green: 0.0705, blue: 0.0745, alpha: 1)), location: 0),
                        .init(color: Color(#colorLiteral(red: 0.1019, green: 0.1019, blue: 0.1137, alpha: 1)), location: 0.72),
                        .init(color: Color(#colorLiteral(red: 0.0823, green: 0.0823, blue: 0.0823, alpha: 1)), location: 1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack {
                    Group {
                        if !isOptionOneEnabled || !isPlaying {
                            if isPlaying {
                                Text("Current Score: \(String(format: "%.1f", score))")
                                    .foregroundColor(.white)
                            } else {
                                Text("Final Score: \(String(format: "%.1f", score))")
                                    .foregroundColor(.white)
                            }
                        } else {
                            Text("Final Score: \(String(format: "%.1f", score))")
                                .hidden()
                        }
                    }
                    .frame(height: 20) // reserve vertical space to prevent shifting
                    ForEach(0..<7) { index in
                        let position = ["QB", "RB", "WR", "WR", "TE", "FLEX", "FLEX"][index]
                        Player(player: $selectedPlayers[index], position: position, canSelect: canSelect) {
                            openPopup(for: position, player: $selectedPlayers[index])
                        }
                    }
                    Group {
                        if isPlaying {
                            DraftingFrom(canSelect: $canSelect)
                        } else {
                            GameOver(onPlayAgain: onPlayAgain,
                                     onGoToLobby: onGoToLobby)
                        }
                    }
                    .frame(height: 200)
                }
                .blur(radius: activePosition == nil ? 0 : 5)
                .disabled(activePosition != nil)

                if let position = activePosition {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { closePopup() }

                    PickPlayer(position: position, onPlayerPicked: onPlayerPicked)
                        .frame(width: 320, height: 320)
                        .transition(.scale)
                        .zIndex(1)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    await randomize()
                }
            }
        }
    }

    func randomize() async {
        await model.randomizeTeam()
        if let team = model.selectedTeam?.db {
            await model.fetchAllPlayersForTeam(team: team)
        }
        canSelect = true
    }

    func openPopup(for position: String, player: Binding<PlayerFromDB?>) {
        Task {
            await MainActor.run {
                model.filterPlayers(position: position)
                activePosition = position
                activePlayer = player
            }
        }
    }

    func closePopup() {
        activePosition = nil
    }

    func onPlayerPicked(playerName: PlayerFromDB) async {
        closePopup()
        activePlayer?.wrappedValue = playerName
        score += activePlayer?.wrappedValue?.points ?? 0
        model.selectedTeam = nil
        playersPicked += 1
        if playersPicked == 7 {
            isPlaying = false
            saveGameToFirestore(score: score, selectedPlayers: selectedPlayers.compactMap { $0 })
        } else {
            canSelect = false
            await randomize()
        }
    }
}

struct PlayAgainButton: View {
    
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Play Again")
                .font(.system(size: 20, weight: .bold))

                .foregroundColor(.black)
                .frame(width: 200, height: 65)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0xC7 / 255, green: 0xEE / 255, blue: 0xFF / 255),
                            Color(red: 0x4D / 255, green: 0x6D / 255, blue: 0xE3 / 255)
                        ]),
                        startPoint: UnitPoint(x: -2.5, y: -2.5),
                        endPoint: UnitPoint(x: 2.5, y: 2.5)
                    )
                )
                .cornerRadius(30)
        }                .frame(width: 200, height: 65)

    }
}

struct LobbyButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text("Lobby")
                .font(.system(size: 20, weight: .bold))

                .foregroundColor(.black)
                .frame(width: 150, height: 55)
                .background(
                    Color(red: 190 / 255, green: 190 / 255, blue: 190 / 255)
                )
                .cornerRadius(30)
        }
    }
}

struct GameOver: View {
    var onPlayAgain: () -> Void
    var onGoToLobby: () -> Void
    var body: some View {
        VStack(spacing: 20) {
            PlayAgainButton(action: onPlayAgain)
            LobbyButton(action: onGoToLobby)
        }
    }
}

struct DraftingFrom: View {
    @Binding var canSelect: Bool
    @EnvironmentObject var model: GameViewModel
    var body: some View {
        VStack {
            Text("Drafting From:")
                .foregroundColor(.white)
            if model.selectedTeam == nil {
                HStack {
                    
                }.frame(width: 200, height: 85)
                    .background(Color(red: 200/255, green: 200/255, blue: 200/255)
.opacity(0.5))
                    .cornerRadius(12)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task {
                            await model.randomizeTeam()
                            canSelect = true
                        }
                    }
            } else {
                HStack {
                    Image("\(model.selectedTeam?.logoPath ?? "")")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                    Text("\(model.selectedTeam?.name ?? "")").foregroundColor(.white)
                }.frame(width: 200, height: 85)
                    .background(model.selectedTeam?.backgroundColor.opacity(0.5))
                    .cornerRadius(12)
            }

        }
    }
}

struct Player: View {
    @Binding var player: PlayerFromDB?
    var position: String = "QB"
    var canSelect: Bool
    var onSelect: () -> Void
    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 0) {
                    VStack {
                        Text(position)
                            .foregroundColor(.black)
                            .padding()
                    }
                    .frame(maxWidth: 75, maxHeight: 50)
                    .background(
                        LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0x4D / 255, green: 0x6D / 255, blue: 0xE3 / 255),  // #4D6DE3
                            Color(red: 0xC7 / 255, green: 0xEE / 255, blue: 0xFF / 255)   // #C7EEFF
                        ]),
                        startPoint: UnitPoint(x: -2.5, y: -2.5),
                        endPoint: UnitPoint(x: 2.5, y: 2.5)
                    ))
                    .cornerRadius(12)

                    Spacer()
                    SelectField(player: player, canSelect: canSelect, onSelect: onSelect, position: position)
                }
                .frame(width: 350, height: 50)
                
            }
        }
        
    }
}

struct SelectField: View {
    @EnvironmentObject var model: GameViewModel

    var player: PlayerFromDB?
    var canSelect: Bool
    var onSelect: () -> Void
    var position: String = "QB"
    var body: some View {
        if player == nil {
            VStack {
                Text("+ Select \(position)")
                    .foregroundColor(canSelect ? .white : .gray)
                    .padding()
            }
            .frame(maxWidth: 300, maxHeight: 50)
            .background(Color.white.opacity(canSelect ? 0.1 : 0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(canSelect ? Color.white : Color.gray, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onTapGesture {
                if canSelect {
                    onSelect()
                }
            }
        } else {
            let parts = player?.name.split(separator: " ", maxSplits: 1)
            let firstName = parts?.first.map(String.init) ?? ""
            let lastName = parts?.dropFirst().first.map(String.init) ?? ""
            HStack {
                Image(TeamsData.teams[player!.team]?.logoPath ?? "").resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding()
                Spacer()
                VStack {
                    Text(firstName)
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .lineLimit(1)
                        .layoutPriority(1)
                        .minimumScaleFactor(0.5)

                    Text(lastName)
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .lineLimit(1)
                        .layoutPriority(1)
                        .minimumScaleFactor(0.5)
                }
                Spacer()
                VStack {
                    Text(String(format: "%.1f", player?.points ?? 0))
                        .foregroundColor(.white)
                    Text(String((player?.year ?? 0)))
                        .foregroundColor(.white)
                        .font(.system(size: 12))
                }
                .frame(width: 55)
                .padding()
                
            }
            .frame(maxWidth: 300, maxHeight: 50)
            .background(TeamsData.teams[player!.team]?.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct PickPlayer: View {
        
    var position: String = "QB"
    var onPlayerPicked: (PlayerFromDB) async -> Void
    @EnvironmentObject var model: GameViewModel
    @FocusState private var isFocused: Bool
    let players: [PlayerFromDB] = []
    @State var searchText = ""
    var team: String {
        model.selectedTeam?.db ?? ""
    }
    var filteredItems: [PlayerFromDB] { model.filteredPlayers(searchText: searchText)
    }
    var body: some View {
        VStack {
            Text("Drafting From: \(team)")
                .foregroundColor(.black)
            TextField("Search \(position)...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isFocused) // link focus state
                .padding(.horizontal)
            List(filteredItems, id: \.id) { item in
                Text(item.name)
                    .onTapGesture {
                        Task {
                            await onPlayerPicked(item)
                        }
                    }
            }.frame(height: 200)
        }.frame(width: 300, height: 300)
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                    Color(red: 0x4D / 255, green: 0x6D / 255, blue: 0xE3 / 255),  // #4D6DE3
                    Color(red: 0xC7 / 255, green: 0xEE / 255, blue: 0xFF / 255)   // #C7EEFF
                ]),
                startPoint: .leading,
                endPoint: .trailing),
            lineWidth: 3)
        )
        .padding()
        .preferredColorScheme(.light)
    }
}

func saveGameToFirestore(score: Double, selectedPlayers: [PlayerFromDB]) {
    guard let userID = Auth.auth().currentUser?.uid else {
        return
    }
    let db = Firestore.firestore()
    let gamesRef = db.collection("users").document(userID).collection("games")
    
    let playerData: [[String: Any]] = selectedPlayers.map { player in
        return [
            "name": player.name,
            "team": player.team,
            "position": player.position,
            "points": player.points,
            "year": player.year
        ]
    }
    
    let gameData: [String: Any] = [
        "score": score,
        "date": Timestamp(date: Date()),
        "players": playerData
    ]
    gamesRef.addDocument(data: gameData) { error in
        if let error = error {
            print("Error saving game: \(error.localizedDescription)")
        } else {
            print("Game saved successfully")

        }
    }
                                        
}

#Preview {
    GameView(
        isOptionOneEnabled: true,
        onPlayAgain: {},
        onGoToLobby: {}
    )
    .environmentObject(GameViewModel())
}

