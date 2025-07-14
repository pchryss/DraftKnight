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
                    Logo()
                    NewGameButton()
                }
            }
        }
    }
}

#Preview {
    HomeView()
}

struct NewGameButton: View {
    var body: some View {
        NavigationLink(destination: StartView()) {
            Text("New Game")
                .font(.custom("Avenir", size: 20))
            
                .foregroundColor(.black)
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

struct Logo: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0xC7 / 255, green: 0xEE / 255, blue: 0xFF / 255),  // #C7EEFF
                            Color(red: 0x4D / 255, green: 0x6D / 255, blue: 0xE3 / 255) // #4D6DE3
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 500, height: 200)
                .mask {
                    HStack(spacing: 20) {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 70, height: 90)
                        Text("draftknight")
                            .font(.custom("Avenir", size: 50))
                    }
                }
            
            HStack(spacing: 20) {
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.clear)
                        .frame(width: 235, height: 90)
                    
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .cornerRadius(20)
                }
                
                Spacer()
            }
            .frame(width: 500, height: 200, alignment: .leading)
        }
    }
}
