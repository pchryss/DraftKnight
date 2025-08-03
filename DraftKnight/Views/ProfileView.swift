//
//  StartView.swift
//  DraftKnight
//
//  Created by Philip Chryssochoos on 6/23/25.
//
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authModel: AuthViewModel

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
                
                // we dont need to pass a binding here because the next view doesnt care about changing it, just the value
                LogOutButton() {
                    authModel.signOut()
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}


struct LogOutButton: View {
    
    let onClick: () -> Void

    var body: some View {
        Button(action: {
            onClick()
        }) {
            Text("Log Out")
                .foregroundColor(.black)
                .font(.custom("Avenir", size: 20))
            
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
