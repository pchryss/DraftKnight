//
//  LeaderboardView.swift
//  DraftKnight
//
//  Created by Philip Chryssochoos on 8/3/25.
//
import SwiftUI

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
                Text("Coming soon...")
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    LeaderboardView()
}
