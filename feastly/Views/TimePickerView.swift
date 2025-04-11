import SwiftUI

struct TimePickerView: View {
    @Binding var selectedTime: Date
    @Binding var selectedDurationHours: Double
    
    // State to store the calculated time options
    @State private var timeOptions: [Date] = []
    
    // Method to generate time options in 15-minute increments starting from minimum feast window
    private func generateTimeOptions() -> [Date] {
        let calendar = Calendar.current
        let now = Date()
        var options: [Date] = []
        
        // Start with current time + 8 hours (minimum feast window)
        guard let minFeastTime = calendar.date(byAdding: .hour, value: 8, to: now) else {
            return options
        }
        
        // Round up to next 15 minutes
        let minuteComponent = calendar.component(.minute, from: minFeastTime)
        let minutesToAdd = (15 - (minuteComponent % 15)) % 15
        guard let startTime = calendar.date(byAdding: .minute, value: minutesToAdd, to: minFeastTime) else {
            return options
        }
        
        // Generate options for the next 16 hours in 15-minute increments (8-24 hour range)
        var currentTime = startTime
        for _ in 0..<64 { // 16 hours * 4 (15-minute increments)
            options.append(currentTime)
            guard let nextTime = calendar.date(byAdding: .minute, value: 15, to: currentTime) else {
                break
            }
            currentTime = nextTime
        }
        
        return options
    }
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    private func isDayAfter(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return !calendar.isDate(date, inSameDayAs: Date())
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Unified time picker with contextual labels
            HStack(alignment: .center, spacing: 12) {
                Text("Feast by")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                if !timeOptions.isEmpty {
                    Picker("Time", selection: $selectedTime) {
                        ForEach(timeOptions, id: \.self) { time in
                            Text(timeFormatter.string(from: time))
                                .tag(time)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 120)
                    .clipped()
                    .onChange(of: selectedTime) { _, newValue in
                        updateDurationFromSelectedTime()
                    }
                }
                
                Text(isDayAfter(selectedTime) ? "tomorrow" : "today")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .frame(height: 150)
            
            // No duration display as requested
        }
        .onAppear {
            // Calculate timeOptions when the view appears
            if timeOptions.isEmpty {
                timeOptions = generateTimeOptions()
                
                // Set initial time to first option (8 hours from now)
                if let firstOption = timeOptions.first, selectedTime == Date() {
                    selectedTime = firstOption
                    updateDurationFromSelectedTime()
                }
            }
        }
    }
    
    private func updateDurationFromSelectedTime() {
        // Calculate hours between now and selected time
        let now = Date()
        let hours = selectedTime.timeIntervalSince(now) / 3600
        
        // Handle if selected time is earlier than now (meaning it's for tomorrow)
        let adjustedHours = hours < 0 ? hours + 24 : hours
        
        // Round to nearest hour and ensure it's within our range (8-24)
        let roundedHours = min(24, max(8, round(adjustedHours)))
        selectedDurationHours = roundedHours
    }
}

#Preview {
    TimePickerView(
        selectedTime: .constant(Date().addingTimeInterval(16 * 3600)),
        selectedDurationHours: .constant(16.0)
    )
}
