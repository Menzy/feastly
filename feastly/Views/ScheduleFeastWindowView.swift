import SwiftUI

struct ScheduleFeastWindowView: View {
    @Binding var selectedDurationHours: Double
    var onBeginFeast: () -> Void
    
    // Initialize selectedFeastTime with a nil value to indicate it's not set yet
    @State private var selectedFeastTime: Date
    
    init(selectedDurationHours: Binding<Double>, onBeginFeast: @escaping () -> Void) {
        self._selectedDurationHours = selectedDurationHours
        self.onBeginFeast = onBeginFeast
        
        // Initialize with a default value (8 hours from now)
        let calendar = Calendar.current
        var initialTime = Date().addingTimeInterval(8 * 3600)
        
        // Round to the nearest 15 minutes
        let minutes = calendar.component(.minute, from: initialTime)
        let minutesToAdd = (15 - (minutes % 15)) % 15
        if let roundedTime = calendar.date(byAdding: .minute, value: minutesToAdd, to: initialTime) {
            initialTime = roundedTime
        }
        
        self._selectedFeastTime = State(initialValue: initialTime)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Time picker component
            TimePickerView(
                selectedTime: $selectedFeastTime,
                selectedDurationHours: $selectedDurationHours
            )
            .padding(.horizontal)
            
            Spacer()
            
            // CTA Button
            Button(action: onBeginFeast) {
                FeastlyTheme.primaryButton("Feast in \(Int(selectedDurationHours)) hours")
            }
            .padding(.bottom, 30)
        }
        .padding()
    }
}

#Preview {
    ScheduleFeastWindowView(
        selectedDurationHours: .constant(16.0),
        onBeginFeast: {}
    )
}
