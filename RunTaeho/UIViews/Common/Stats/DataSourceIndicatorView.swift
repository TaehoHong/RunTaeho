import SwiftUI

struct DataSourceIndicatorView: View {
    let sourceType: DataSourceType
    
    private var displayInfo: (text: String, icon: String, color: Color) {
        switch sourceType {
        case .watch:
            return ("WATCH", sourceType.iconName, .blue)
        case .phone:
            return ("PHONE", sourceType.iconName, .orange)
        case .healthKit:
            return ("HEALTH", sourceType.iconName, .green)
        case .mock:
            return ("TEST", sourceType.iconName, .purple)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(displayInfo.text)
                .font(CustomFont.stats())
                .foregroundColor(displayInfo.color)
                .accessibility(label: Text("Data source: \(sourceType.displayName)"))
            
            Image(systemName: displayInfo.icon)
                .font(.title3)
                .foregroundColor(displayInfo.color)
                .accessibility(hidden: true)
        }
        .frame(width: 75, height: 45)
        .animation(.easeInOut(duration: 0.3), value: sourceType)
    }
}