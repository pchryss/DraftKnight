//
//  AuthViewModel.swift
//  DraftKnight
//
//  Created by Philip Chryssochoos on 8/2/25.
//
import Foundation
import FirebaseAuth
import Combine

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var username = ""
    @Published var fetchedUsername = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isAuthenticated = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        if let user = Auth.auth().currentUser {
            self.isAuthenticated = true
            fetchUsername(for: user.uid)
        } else {
            self.isAuthenticated = false
        }
    }
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else if let user = result?.user {
                    self?.isAuthenticated = true
                    self?.fetchUsername(for: user.uid)
                }
            }
        }
    }
    
    func signUp() {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty, !username.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        
        let usernamePattern = "^[a-zA-Z0-9_]{3,20}$"
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernamePattern)
        guard usernamePredicate.evaluate(with: username) else {
            errorMessage = "Username must be 3-20 characters and contain only letters, numbers, or underscores."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let db = Firestore.firestore()
        
        db.collection("users").whereField("username", isEqualTo: username).getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = "Failed to check username: \(error.localizedDescription)"
                    return
                }
                
                if let snapshot = snapshot, !snapshot.documents.isEmpty {
                    self.isLoading = false
                    self.errorMessage = "Username already taken. Please choose another."
                    return
                }
                
                // 5. Create the user since username is valid and unique
                Auth.auth().createUser(withEmail: self.email, password: self.password) { result, error in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        if let error = error {
                            self.errorMessage = error.localizedDescription
                        } else if let user = result?.user {
                            // Save user data in Firestore
                            db.collection("users").document(user.uid).setData([
                                "username": self.username,
                                "email": self.email
                            ]) { error in
                                if let error = error {
                                    print("Failed to save user data: \(error.localizedDescription)")
                                } else {
                                    print("User data saved successfully!")
                                }
                            }
                            self.isAuthenticated = true
                            self.fetchedUsername = self.username
                        }
                    }
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.email = ""
                self.password = ""
                self.confirmPassword = ""
                self.username = ""
                self.fetchedUsername = ""
            }
        } catch {
            print("Sign out error: \(error.localizedDescription)")
        }
    }
    
    private func fetchUsername(for uid: String) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            if let data = snapshot?.data(), let username = data["username"] as? String {
                DispatchQueue.main.async {
                    self?.fetchedUsername = username
                }
            }
        }
    }
}

