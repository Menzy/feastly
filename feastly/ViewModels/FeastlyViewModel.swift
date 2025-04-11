import Foundation
import SwiftUI
import Combine

class FeastlyViewModel: ObservableObject {
    @Published var currentFeastWindow: FeastWindow?
    @Published var scheduledFeastWindows: [FeastWindow] = []
    @Published var selectedDate: Date = Date()
    @Published var selectedDuration: TimeInterval = 16 * 3600 // Default 16 hours
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        startTimer()
        loadSavedData()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateFeastWindowStatus()
        }
    }
    
    private func updateFeastWindowStatus() {
        if let feastWindow = currentFeastWindow, feastWindow.isActive {
            if Date() >= feastWindow.endDate {
                completeFeastWindow()
            }
            objectWillChange.send()
        }
    }
    
    // MARK: - Feast Window Management
    
    func beginFeastWindow(duration: TimeInterval) {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(duration)
        
        let newFeastWindow = FeastWindow(
            startDate: startDate,
            endDate: endDate,
            isActive: true
        )
        
        currentFeastWindow = newFeastWindow
        scheduledFeastWindows.append(newFeastWindow)
        saveData()
    }
    
    func completeFeastWindow() {
        if var feastWindow = currentFeastWindow {
            feastWindow.isActive = false
            
            if let index = scheduledFeastWindows.firstIndex(where: { $0.id == feastWindow.id }) {
                scheduledFeastWindows[index] = feastWindow
            }
            
            currentFeastWindow = nil
            saveData()
        }
    }
    
    func cancelFeastWindow() {
        if let feastWindow = currentFeastWindow, 
           let index = scheduledFeastWindows.firstIndex(where: { $0.id == feastWindow.id }) {
            scheduledFeastWindows.remove(at: index)
            currentFeastWindow = nil
            saveData()
        }
    }
    
    func getFeastWindowsForDate(_ date: Date) -> [FeastWindow] {
        let calendar = Calendar.current
        return scheduledFeastWindows.filter { feastWindow in
            calendar.isDate(feastWindow.startDate, inSameDayAs: date)
        }
    }
    
    func hasActiveFeastWindow() -> Bool {
        return currentFeastWindow?.isActive == true
    }
    
    // MARK: - Persistence
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(scheduledFeastWindows) {
            UserDefaults.standard.set(encoded, forKey: "scheduledFeastWindows")
        }
        
        if let currentFeastWindow = currentFeastWindow,
           let encoded = try? JSONEncoder().encode(currentFeastWindow) {
            UserDefaults.standard.set(encoded, forKey: "currentFeastWindow")
        } else {
            UserDefaults.standard.removeObject(forKey: "currentFeastWindow")
        }
    }
    
    private func loadSavedData() {
        if let savedFeastWindows = UserDefaults.standard.data(forKey: "scheduledFeastWindows"),
           let decodedFeastWindows = try? JSONDecoder().decode([FeastWindow].self, from: savedFeastWindows) {
            scheduledFeastWindows = decodedFeastWindows
        }
        
        if let savedCurrentFeastWindow = UserDefaults.standard.data(forKey: "currentFeastWindow"),
           let decodedCurrentFeastWindow = try? JSONDecoder().decode(FeastWindow.self, from: savedCurrentFeastWindow) {
            // Only restore active feast windows
            if decodedCurrentFeastWindow.isActive && decodedCurrentFeastWindow.endDate > Date() {
                currentFeastWindow = decodedCurrentFeastWindow
            } else {
                // Mark as completed if the end date has passed
                var completedWindow = decodedCurrentFeastWindow
                completedWindow.isActive = false
                
                if let index = scheduledFeastWindows.firstIndex(where: { $0.id == completedWindow.id }) {
                    scheduledFeastWindows[index] = completedWindow
                }
                
                saveData()
            }
        }
    }
}
