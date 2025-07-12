//
//  CounterViewModel.swift
//  DraftKnight
//
//  Created by Philip Chryssochoos on 6/23/25.
//
import Foundation
import Combine
// create a class of the same name by convention
// ObservableObject tells the UI to re-render the view if anything changes
class CounterViewModel: ObservableObject {
    // flags the variable. If it changes, the view is re-rendered
    @Published var count = 0
    func increment() {
        count += 1
    }
}
