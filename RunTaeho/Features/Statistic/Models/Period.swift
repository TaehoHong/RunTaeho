import Foundation

enum Period {
    case week, month, year
    
    var title: String {
        switch self {
        case .week: return "주"
        case .month: return "월"
        case .year: return "년"
        }
    }
    
    var periodTitle: String {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .week:
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "M월"
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "d"
            
            if calendar.component(.month, from: weekStart) == calendar.component(.month, from: weekEnd) {
                return "\(monthFormatter.string(from: weekStart)) \(dayFormatter.string(from: weekStart))~\(dayFormatter.string(from: weekEnd))일"
            } else {
                return "\(monthFormatter.string(from: weekStart)) \(dayFormatter.string(from: weekStart))일~\(monthFormatter.string(from: weekEnd)) \(dayFormatter.string(from: weekEnd))일"
            }
            
        case .month:
            let formatter = DateFormatter()
            formatter.dateFormat = "M월"
            return formatter.string(from: now)
            
        case .year:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년"
            return formatter.string(from: now)
        }
    }
}