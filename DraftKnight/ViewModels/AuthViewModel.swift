//
//  AuthViewModel.swift
//  DraftKnight
//
//  Created by Philip Chryssochoos on 8/2/25.
//
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var user: User? = Auth.auth().currentUser
    
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let user = result?.user {
                DispatchQueue.main.async {
                    self.user = user
                }
            } else {
                print("Signup error: \(error?.localizedDescription ?? "No error")")
            }
        }
    }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let user = result?.user {
                DispatchQueue.main.async {
                    self.user = user
                }
            } else {
                print("Signin error: \(error?.localizedDescription ?? "No error")")
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            print("Signout error: \(error.localizedDescription)")
        }
    }
}
