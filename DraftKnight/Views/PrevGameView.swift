//
//  PrevGameView.swift
//  DraftKnight
//
//  Created by Philip Chryssochoos on 8/8/25.
//

import SwiftUI

struct PrevGameView: View {
    @Environment(\.dismiss) private var dismiss
    var gameData: GameData
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
                Text("Final Score: \(String(format: "%.1f", gameData.score))")
                    .foregroundColor(.white)
                ForEach(0..<7) { index in
                    let position = ["QB", "RB", "WR", "WR", "TE", "FLEX", "FLEX"][index]
                    PrevPlayer(player: gameData.players[index], position: position)
                    }
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
        }
    }
}

struct PrevPlayer: View {
    var player: PlayerFromDB
    var position: String
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
                    PrevSelectField(player: player, position: position)
                }
                .frame(width: 350, height: 50)
                
            }
        }
        
    }
}

struct PrevSelectField: View {
    var player: PlayerFromDB
    var position: String = "QB"
    var body: some View {
        let parts = player.name.split(separator: " ", maxSplits: 1)
        let firstName = parts.first.map(String.init) ?? ""
        let lastName = parts.dropFirst().first.map(String.init) ?? ""
        HStack {
            Image(TeamsData.teams[player.team]?.logoPath ?? "").resizable()
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
                Text(String(format: "%.1f", player.points))
                    .foregroundColor(.white)
                Text(String((player.year)))
                    .foregroundColor(.white)
                    .font(.system(size: 12))
            }
            .frame(width: 55)
            .padding()
            
        }
        .frame(maxWidth: 300, maxHeight: 50)
        .background(TeamsData.teams[player.team]?.backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
