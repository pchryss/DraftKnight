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
            
            StartView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(0)
            
            NavigationStack {
                StartView()

            }
                .tabItem {
                    Label("Start", systemImage: "house.fill")
                }
                .tag(1)
            
            StartView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}
