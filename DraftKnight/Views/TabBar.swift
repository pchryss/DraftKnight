//
//  TabView.swift
//  DraftKnight
//
//  Created by Philip Chryssochoos on 8/2/25.
//

import SwiftUI

struct TabBar: View {
    @State private var selectedTab = 1  // 0=History, 1=StartView, 2=Profile
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            LeaderboardView()
                .tabItem {
                    Label("Leaderboard", systemImage: "chart.bar.fill")
                }
                .tag(0)
            
            NavigationStack {
                StartView()

            }
                .tabItem {
                    Label("Play", systemImage: "gamecontroller.fill")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}
