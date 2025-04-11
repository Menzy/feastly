//
//  ContentView.swift
//  feastly
//
//  Created by Wan Menzy on 10/04/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FeastlyViewModel()
    @State private var selectedDurationHours: Double = 16
    @State private var scrolledDate: Date = Date()
    @State private var hasAppearedOnce = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d. MMM yyyy"
        return formatter
    }()
    
    private let calendar = Calendar.current
    
    // Custom haptic feedback controller
    private let selectionHaptic = UISelectionFeedbackGenerator()
    private let edgeFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        NavigationStack {
            ZStack {
                FeastlyTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Date display - aligned left now
                    Text(dateFormatter.string(from: scrolledDate).uppercased())
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 16)
                        .padding(.horizontal)
                    
                    // JOURNAL Header
                    HStack {
                        Text("Feastly")
                            .font(.system(size: 40, weight: .black))
                            .tracking(1.5)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Menu button
                        Button(action: {
                            // Menu action
                        }) {
                            Image(systemName: "ellipsis")
                                .font(.title3)
                                .foregroundColor(.primary)
                                .padding(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Horizontal Calendar that automatically scrolls when date changes
                    HorizontalCalendarView(selectedDate: $scrolledDate)
                        .padding(.top, 12)
                        .onChange(of: scrolledDate) { newDate in
                            // Update viewModel's selectedDate when calendar date changes
                            viewModel.selectedDate = newDate
                        }
                    
                    ScheduleFeastWindowView(
                        selectedDurationHours: $selectedDurationHours,
                        onBeginFeast: {
                            viewModel.beginFeastWindow(duration: selectedDurationHours * 3600)
                        }
                    )
                    .padding(.top, 24)
                    
                    
                    Spacer() // Push content to the top
                }
                .contentShape(Rectangle()) // Make entire area tappable for gestures
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded { value in
                            // Determine if it's a left or right swipe
                            let isLeftSwipe = value.translation.width < 0
                            let isRightSwipe = value.translation.width > 0
                            
                            // Only process horizontal swipes
                            if abs(value.translation.width) > abs(value.translation.height) {
                                switchDay(isLeftSwipe: isLeftSwipe, isRightSwipe: isRightSwipe)
                            }
                        }
                )
            }
            .navigationBarHidden(true)
            .onAppear {
                // Initialize with today's date when the view appears
                selectionHaptic.prepare()
                edgeFeedback.prepare()
                
                // Only initialize dates if this is the first appearance
                if !hasAppearedOnce {
                    hasAppearedOnce = true
                    
                    // Initialize the view model's selected date with today
                    let today = Date()
                    
                    // Set both dates simultaneously to ensure consistency
                    viewModel.selectedDate = today
                    scrolledDate = today
                }
            }
        }
        .accentColor(FeastlyTheme.primary)
    }
    
    
    // Check if date is in current month
    private func isDateInCurrentMonth(_ date: Date) -> Bool {
        let today = Date()
        return calendar.isDate(date, equalTo: today, toGranularity: .month)
    }
    
    // Function to switch to the previous or next day
    private func switchDay(isLeftSwipe: Bool, isRightSwipe: Bool) {
        // Get the current date
        let currentDate = scrolledDate
        
        // Determine the new date based on swipe direction
        if isLeftSwipe {
            // Next day
            if let newDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                if isDateInCurrentMonth(newDate) {
                    // Apply the date change with animation to trigger calendar scrolling
                    scrolledDate = newDate
                    // Synchronize the view model date with scrolledDate
                    viewModel.selectedDate = newDate
                    
                    // Provide haptic feedback
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } else {
                    // Provide edge feedback for month boundary
                    edgeFeedback.notificationOccurred(.warning)
                }
            }
        } else if isRightSwipe {
            // Previous day
            if let newDate = calendar.date(byAdding: .day, value: -1, to: currentDate) {
                if isDateInCurrentMonth(newDate) {
                    // Apply the date change with animation to trigger calendar scrolling
                    scrolledDate = newDate
                    // Synchronize the view model date with scrolledDate
                    viewModel.selectedDate = newDate
                    
                    // Provide haptic feedback
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } else {
                    // Provide edge feedback for month boundary
                    edgeFeedback.notificationOccurred(.warning)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
