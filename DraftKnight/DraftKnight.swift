//
//  DraftKnightApp.swift
//  DraftKnight
//
//  Created by Philip Chryssochoos on 7/11/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}


@main
struct DraftKnight: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var authModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authModel)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var authModel: AuthViewModel
    
    var body: some View {
        Group {
            if authModel.isAuthenticated {
                TabBar()
            } else {
                AuthView()
            }
        }
    }
}
