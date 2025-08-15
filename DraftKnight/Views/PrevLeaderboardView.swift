//
//  PrevLeaderbordView.swift
//  DraftKnight
//
//  Created by Philip Chryssochoos on 8/8/25.
//

import SwiftUI

struct PrevLeaderboardView: View {
    @Environment(\.dismiss) private var dismiss
    var gameData: LeaderboardEntry
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
                Text("\(gameData.username)")
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
