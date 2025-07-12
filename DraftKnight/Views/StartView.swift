//
//  StartView.swift
//  DraftKnight
//
//  Created by Philip Chryssochoos on 6/23/25.
//
import SwiftUI

struct StartView: View {
    @State private var isOptionOneEnabled = false

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
                    //AppHomeLogo()
                    // we are passing a binding here, so that GameSettings can read and write here
                    GameSettings(isOptionOneEnabled: $isOptionOneEnabled)
                    
                    // we dont need to pass a binding here because the next view doesnt care about changing it, just the value
                    StartButton(isOptionOneEnabled: isOptionOneEnabled)
                        //.padding(.top, 250)
                }
            }
        }
    }
}

#Preview {
    StartView()
}

struct GameSettings: View {
    
    @Binding var isOptionOneEnabled: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            checkbox("Hide Points", isOn: $isOptionOneEnabled)
        }
        .padding()
    }

    @ViewBuilder
    private func checkbox(_ label: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 8) {
            Button(action: {
                isOn.wrappedValue.toggle()
            }) {
                Image(systemName: isOn.wrappedValue ? "checkmark.square" : "square")
                    .foregroundColor(.white)
            }
            Text(label)
                .foregroundColor(.white)
        }
    }
}

struct StartButton: View {
        
    var isOptionOneEnabled: Bool
    
    var body: some View {
        NavigationLink(destination: GameView(isOptionOneEnabled: isOptionOneEnabled)) {
            Text("Start Game")
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
