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
struct AuthView: View {
    
    // @StateObject creates a single instance of a view model and tells SwiftUI to watch for changes
    @StateObject private var viewModel = CounterViewModel()
    @State var usingLogin = true
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
                    Logo().padding()
                    Input(usingLogin: $usingLogin).padding()
                    AuthButton(usingLogin: $usingLogin).padding()
                }
            }
        }
    }
}

#Preview {
    AuthView()
}

struct InputField: View {
    var placeholder: String
    @Binding var input: String
    var body: some View {
        TextField(placeholder, text: $input)
            .foregroundColor(.black)
            .padding(.leading, 20)
            .background(
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color(red: 230 / 255, green: 230 / 255, blue: 230 / 255))
                    .frame(width: 325, height: 65)
            )
            .frame(width: 325, height: 65)
    }
}

struct Toggle: View {
    @Binding var usingLogin: Bool
    var body: some View {
        VStack {
            ToggleButton(text: usingLogin ? "Log In" : "Sign Up")
                .padding(.leading, usingLogin ? -55 : 55)
                .animation(.easeInOut(duration: 0.2), value: usingLogin)
                .onTapGesture {
                    usingLogin.toggle()
                }
        }
        .frame(width: 175, height: 70)
        .background(RoundedRectangle(cornerRadius: 40)
            .fill(LinearGradient(gradient: Gradient(stops: [
                .init(color: Color(#colorLiteral(red: 0.7803921699523926, green: 0.9333333373069763, blue: 1, alpha: 1)), location: 0),
                .init(color: Color(#colorLiteral(red: 0.3019607961177826, green: 0.4274509847164154, blue: 0.8901960849761963, alpha: 1)), location: 1)]),
                startPoint: UnitPoint(x: 0.042662109200828774, y: 3.0333335879768804),
                endPoint: UnitPoint(x: 1.3225256172828643, y: -2.2916668331493026))
            ).opacity(0.3)
        )

    }
}


struct ToggleButton: View {
    var text: String
    var body: some View {
        ZStack {
            Text("Log In")
                .opacity(text == "Log In" ? 1 : 0)
            Text("Sign Up")
                .opacity(text == "Sign Up" ? 1 : 0)
        }
        .font(.custom("Avenir", size: 20))
        .foregroundColor(.black)
        .frame(width: 100, height: 60)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0xC7 / 255, green: 0xEE / 255, blue: 0xFF / 255),
                    Color(red: 0x4D / 255, green: 0x6D / 255, blue: 0xE3 / 255)
                ]),
                startPoint: UnitPoint(x: -2.5, y: -2.5),
                endPoint: UnitPoint(x: 2.5, y: 2.5)
            )
        )
        .cornerRadius(30)
        
    }
}

struct Input: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirm = ""

    @Binding var usingLogin: Bool

    var body: some View {
        VStack {
            Toggle(usingLogin: $usingLogin)
            InputField(placeholder: "Email", input: $email)
            InputField(placeholder: "Password", input: $password)
            Group {
                if usingLogin {
                    Text("Forgot Password")
                        .foregroundColor(Color(red: 230 / 255, green: 230 / 255, blue: 230 / 255))
                } else {
                    InputField(placeholder: "Confirm Password", input: $confirm)
                }
            }
            .frame(height: 65)
            .animation(.easeInOut(duration: 1), value: usingLogin)

        }
    }
}

struct AuthButton: View {
    @Binding var usingLogin: Bool
    var body: some View {
        NavigationLink(destination: StartView()) {
            Text(usingLogin ? "Log In" : "Create Account")
                .font(.custom("Avenir", size: 20))
            
                .foregroundColor(.black)
                .frame(width: 200, height: 65)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0xC7 / 255, green: 0xEE / 255, blue: 0xFF / 255),
                            Color(red: 0x4D / 255, green: 0x6D / 255, blue: 0xE3 / 255)
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
                .frame(width: 500, height: 100)
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
                
            }
            .frame(width: 500, height: 100, alignment: .leading)
        }
    }
}
