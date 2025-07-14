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
    
    @EnvironmentObject private var model: GameViewModel
    @State var activePosition: String? = nil
    @State var activePlayer: Binding<PlayerFromDB?>?

    @State var canSelect: Bool = false
    @State var score: Double = 0
    @State var selectedPlayers: [PlayerFromDB?] = [nil, nil, nil, nil, nil, nil, nil]
    
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
                        .init(color: Color(#colorLiteral(red: 0.07058823853731155, green: 0.07058823853731155, blue: 0.07450980693101883, alpha: 1)), location: 0),
                        .init(color: Color(#colorLiteral(red: 0.10196078568696976, green: 0.10196078568696976, blue: 0.11372549086809158, alpha: 1)), location: 0.7195587754249573),
                        .init(color: Color(#colorLiteral(red: 0.08235294371843338, green: 0.08235294371843338, blue: 0.08235294371843338, alpha: 1)), location: 1)]),
                            startPoint: UnitPoint(x: 1.1131840781819538, y: 0.034324952532510944),
                            endPoint: UnitPoint(x: -0.08582107197307076, y: 0.9084668511127786)
                )
                .ignoresSafeArea()
                
                VStack {
                    if isOptionOneEnabled {
                        Text("Current Score: "+(String(format: "%.2f", score)))
                            .foregroundColor(.white)
                    }
                    Player(player: $selectedPlayers[0], position: "QB", canSelect: canSelect) {
                        openPopup(for: "QB", player: $selectedPlayers[0])
                    }
                    Player(player: $selectedPlayers[1], position: "RB", canSelect: canSelect) {
                        openPopup(for: "RB", player: $selectedPlayers[1])
                    }
                    Player(player: $selectedPlayers[2], position: "WR", canSelect: canSelect) {
                        openPopup(for: "WR", player: $selectedPlayers[2])
                    }
                    Player(player: $selectedPlayers[3], position: "WR", canSelect: canSelect) {
                        openPopup(for: "WR", player: $selectedPlayers[3])
                    }
                    Player(player: $selectedPlayers[4], position: "TE", canSelect: canSelect) {
                        openPopup(for: "TE", player: $selectedPlayers[4])
                    }
                    Player(player: $selectedPlayers[5], position: "FLEX", canSelect: canSelect) {
                        openPopup(for: "FLEX", player: $selectedPlayers[5])
                    }
                    Player(player: $selectedPlayers[6], position: "FLEX", canSelect: canSelect) {
                        openPopup(for: "FLEX", player: $selectedPlayers[6])
                    }
                    DraftingFrom(canSelect: $canSelect)
                }
                .blur(radius: activePosition == nil ? 0 : 5)
                .disabled(activePosition != nil)
                
                if let position = activePosition {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            closePopup()
                        }
                    
                    PickPlayer(position: position, onPlayerPicked: onPlayerPicked)
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
        await model.randomizeTeam()
        canSelect = true
    }
    
    func openPopup(for position: String, player: Binding<PlayerFromDB?>) {
        activePosition = position
        activePlayer = player
    }
    func closePopup() {
        activePosition = nil
    }
    
    func onPlayerPicked(playerName: PlayerFromDB) async {
        closePopup()
        activePlayer?.wrappedValue = playerName
        score += activePlayer?.wrappedValue?.points ?? 0
        model.selectedTeam = nil
        canSelect = false
        await randomize()
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
                Image(model.teams[player!.team]?.logoPath ?? "").resizable()
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
                    Text(String(format: "%.2f", player?.points ?? 0))
                        .foregroundColor(.white)
                    Text(String((player?.year ?? 0)))
                        .foregroundColor(.white)
                        .font(.system(size: 12))
                }
                .frame(width: 55)
                .padding()
                
            }
            .frame(maxWidth: 300, maxHeight: 50)
            .background(model.teams[player!.team]?.backgroundColor)
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
        .onAppear {
            model.fetchPlayers(team: team, position: position)
        }
    }
}

#Preview {
    GameView().environmentObject(GameViewModel())
}

