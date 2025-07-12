//
//  GameView.swift
//  DraftKnight
//
//  Created by Philip Chryssochoos on 6/25/25.
//


import SwiftUI

// Views are almost always defined using structs instead of classes
//      They are lightweight, and be recreated easily, and have value semantics (for diffing)
//
// : View says ContentView conforms to the View protool
//      A view is anything that can be displayed on screen
//      Requires us to provide a body property that defines the view layout
struct GameView: View {
    
    @StateObject private var gameModel = GameViewModel()
    @State var activePosition: String? = nil
    @State var activePlayer: Binding<String>?

    @State var canSelect: Bool = false
    
    @State var selectedPlayers = Array(repeating: "", count: 7)
    
    var isOptionOneEnabled: Bool = true
    // @StateObject creates a single instance of a view model and tells SwiftUI to watch for changes
    
    // required property of the view protocol
    // some View says we are returning a view, but not specifing
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea(edges: .all)
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(red: 27/255, green: 24/255, blue: 49/255), location: 0),
                        .init(color: Color(red: 54/255, green: 48/255, blue: 98/255).opacity(0.3), location: 0.5),
                        .init(color: Color(red: 27/255, green: 24/255, blue: 49/255), location: 1)
                    ]),
                    startPoint: UnitPoint(x: 1.68, y: -0.24),
                    endPoint: UnitPoint(x: -0.70, y: 0.75)
                )
                .ignoresSafeArea()
                
                VStack {
                    if isOptionOneEnabled {
                        Text("Current Score: 0")
                            .foregroundColor(.white)
                    }
                    Player(playerName: $selectedPlayers[0], position: "QB", canSelect: canSelect) {
                        openPopup(for: "QB", player: $selectedPlayers[0])
                    }
                    Player(playerName: $selectedPlayers[1], position: "RB", canSelect: canSelect) {
                        openPopup(for: "RB", player: $selectedPlayers[1])
                    }
                    Player(playerName: $selectedPlayers[2], position: "WR", canSelect: canSelect) {
                        openPopup(for: "WR", player: $selectedPlayers[2])
                    }
                    Player(playerName: $selectedPlayers[3], position: "WR", canSelect: canSelect) {
                        openPopup(for: "WR", player: $selectedPlayers[3])
                    }
                    Player(playerName: $selectedPlayers[4], position: "TE", canSelect: canSelect) {
                        openPopup(for: "TE", player: $selectedPlayers[4])
                    }
                    Player(playerName: $selectedPlayers[5], position: "FLEX", canSelect: canSelect) {
                        openPopup(for: "FLEX", player: $selectedPlayers[5])
                    }
                    Player(playerName: $selectedPlayers[6], position: "FLEX", canSelect: canSelect) {
                        openPopup(for: "FLEX", player: $selectedPlayers[6])
                    }
                    DraftingFrom(model: gameModel, canSelect: $canSelect)
                }
                .blur(radius: activePosition == nil ? 0 : 5)
                .disabled(activePosition != nil)
                
                if let position = activePosition {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            closePopup()
                        }
                    
                    PickPlayer(position: position, onPlayerPicked: onPlayerPicked, gameModel: gameModel)
                    .frame(width: 320, height: 320)
                    .transition(.scale)
                    .zIndex(1)
                }
            }
        }.onAppear() {
            Task {
                await randomize()
            }
        }
    }
    
    func randomize() async {
        await gameModel.randomizeTeam()
        canSelect = true
    }
    
    func openPopup(for position: String, player: Binding<String>) {
        activePosition = position
        activePlayer = player
    }
    func closePopup() {
        activePosition = nil
    }
    
    func onPlayerPicked(playerName: String) async {
        closePopup()
        activePlayer?.wrappedValue = playerName
        gameModel.selectedTeam = nil
        canSelect = false
        await randomize()
    }
}

struct DraftingFrom: View {
    
    @ObservedObject var model: GameViewModel
    @Binding var canSelect: Bool
    
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
    @Binding var playerName: String
    var position: String = "QB"
    var canSelect: Bool
    var onSelect: () -> Void
    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 0) {
                    VStack {
                        Text(position)
                            .foregroundColor(.white)
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
                    if playerName == "" {
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
                        .onTapGesture {
                            if canSelect {
                                onSelect()
                            }
                        }
                    } else {
                        VStack {
                            Text(playerName)
                                .foregroundColor(canSelect ? .white : .gray)
                                .padding()
                        }
                        .frame(maxWidth: 300, maxHeight: 50)
                        .background(Color.white.opacity(canSelect ? 0.1 : 0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(canSelect ? Color.white : Color.gray, lineWidth: 2)
                        )
                    }
                }
                .frame(width: 300, height: 50)
                
            }
        }
        
    }
}

struct PickPlayer: View {
        
    var position: String = "QB"
    var onPlayerPicked: (String) async -> Void
    
    @FocusState private var isFocused: Bool
    let players: [PlayerFromDB] = []
    @State var searchText = ""
    @ObservedObject var gameModel: GameViewModel
    var team: String {
        gameModel.selectedTeam?.db ?? ""
    }
    var filteredItems: [PlayerFromDB] { gameModel.filteredPlayers(searchText: searchText)
    }
    var body: some View {
        VStack {
            Text("Drafting From: \(team)")
            TextField("Search \(position)...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isFocused) // link focus state
                .padding(.horizontal)
            List(filteredItems, id: \.id) { item in
                Text(item.name)
                    .onTapGesture {
                        Task {
                            await onPlayerPicked(item.name)
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
        .onAppear {
            gameModel.fetchPlayers(team: team, position: position)
        }
    }
}

#Preview {
    GameView()
}

