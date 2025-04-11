import SwiftUI

struct HorizontalCalendarView: View {
    @Binding var selectedDate: Date
    @State private var days: [Date] = []
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    // Haptic feedback
    private let selectionHaptic = UISelectionFeedbackGenerator()
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                // Add spacing before first item to allow centering
                HStack(spacing: 12) {
                    // Add spacers to ensure center alignment works on all screen sizes
                    Spacer()
                        .frame(width: UIScreen.main.bounds.width / 2 - 20) // Half screen minus half item width
                    
                    ForEach(days, id: \.self) { day in
                        dayView(for: day)
                            .id(day)
                    }
                    
                    // Add spacer at the end to ensure center alignment works
                    Spacer()
                        .frame(width: UIScreen.main.bounds.width / 2 - 20) // Half screen minus half item width
                }
                .padding(.horizontal)
            }
            .scrollClipDisabled()
            .onAppear {
                // Generate days and prepare haptic feedback
                generateDaysForCurrentMonth()
                selectionHaptic.prepare()
                
                // Scroll to selected date on initial load
                DispatchQueue.main.async {
                    scrollToDate(selectedDate, proxy: proxy)
                }
            }
            .onChange(of: selectedDate) { newDate in
                // Scroll when selected date changes (from swipe gesture)
                scrollToDate(newDate, proxy: proxy)
            }
        }
    }
    
    private func scrollToDate(_ date: Date, proxy: ScrollViewProxy) {
        // Find the exact date in our days array
        if let dayToScrollTo = days.first(where: { calendar.isDate($0, inSameDayAs: date) }) {
            // Use a more noticeable animation for the scroll effect
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                proxy.scrollTo(dayToScrollTo, anchor: .center)
            }
        }
    }
    
    private func dayView(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let isSelectedToday = isToday && isSelected
        
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedDate = date
            }
            // Trigger haptic feedback on selection
            selectionHaptic.selectionChanged()
        }) {
            // Only show the day number with smaller text
            Text(dateFormatter.string(from: date))
                .font(.system(size: 16))
                .foregroundColor(isSelectedToday ? .white : .gray) // Only today's text is white when selected
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(getBackgroundColor(isToday: isToday, isSelected: isSelected))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getBackgroundColor(isToday: Bool, isSelected: Bool) -> Color {
        if isToday && isSelected {
            // Today's date has a black background only when selected
            return .black
        } else if isSelected {
            // Selected date (not today) has a light gray background
            return Color.gray.opacity(0.2)
        } else {
            // Other dates have no background
            return Color.clear
        }
    }
    
    private func generateDaysForCurrentMonth() {
        var currentDays: [Date] = []
        
        let today = Date()
        
        // Get the start of the current month
        let components = calendar.dateComponents([.year, .month], from: today)
        if let startOfMonth = calendar.date(from: components),
           let range = calendar.range(of: .day, in: .month, for: startOfMonth) {
            
            // Generate dates for each day in the current month
            for day in range {
                if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                    currentDays.append(date)
                }
            }
        }
        
        days = currentDays
    }
}

#Preview {
    HorizontalCalendarView(selectedDate: .constant(Date()))
        .background(FeastlyTheme.background)
} 