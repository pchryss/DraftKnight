//
//  ContentView.swift
//  DraftKnight
//
//  Created by Philip Chryssochoos on 6/23/25.
//

import SwiftUI
// Views are almost always defined using structs instead of classes
//      They are lightweight, and be recreated easily, and have value semantics (for diffing)
//
// : View says ContentView conforms to the View protool
//      A view is anything that can be displayed on screen
//      Requires us to provide a body property that defines the view layout
struct HomeView: View {
    
    // @StateObject creates a single instance of a view model and tells SwiftUI to watch for changes
    @StateObject private var viewModel = CounterViewModel()
    // required property of the view protocol
    // some View says we are returning a view, but not specifing
    var body: some View {
        NavigationStack {
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
                        //AppHomeLogo()
                        NewGameButton()
                            //.padding(.top, 250)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}

struct AppHomeLogo: View {
    var body: some View {
        HStack(spacing: 0) {
            Image("Logo") // <- Replace with your asset name
                .resizable()
                .scaledToFit()
                .frame(width: 110, height: 160)
            
            Text("DraftKnight")
                .font(.system(size: 40, weight: .bold))
                .overlay(LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0x4D / 255, green: 0x6D / 255, blue: 0xE3 / 255),  // #4D6DE3
                        Color(red: 0xC7 / 255, green: 0xEE / 255, blue: 0xFF / 255)   // #C7EEFF
                    ]),
                    startPoint: UnitPoint(x: -2.5, y: -2.5),
                    endPoint: UnitPoint(x: 2.5, y: 2.5)
                ))
                .mask(
                    Text("DraftKnight")
                        .font(.system(size: 40, weight: .bold))
                )
        }
        .padding()
    }
}

struct NewGameButton: View {
    var body: some View {
        NavigationLink(destination: StartView()) {
            Text("New Game")
                .foregroundColor(.black)
                .font(.system(size: 20, weight: .regular, design: .default))
                .frame(width: 150, height: 65)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0x4D / 255, green: 0x6D / 255, blue: 0xE3 / 255),  // #4D6DE3
                            Color(red: 0xC7 / 255, green: 0xEE / 255, blue: 0xFF / 255)   // #C7EEFF
                        ]),
                        startPoint: UnitPoint(x: -2.5, y: -2.5),
                        endPoint: UnitPoint(x: 2.5, y: 2.5)
                    )
                )
                .cornerRadius(30)
        }
    }
}
// glowing start button
// slow "flowing" animation
