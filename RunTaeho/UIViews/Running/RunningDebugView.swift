//
//  RunningDebugView.swift
//  RunTaeho
//
//  Created by Hong Taeho on 8/5/25.
//

import Foundation
import SwiftUI


struct DebugView: View {
    
    @ObservedObject var viewModel: RunningViewModel
    @State private var isExpanded = true

    var body: some View {
        HStack(alignment: .top) {

            VelocityDevButtonView(viewModel: viewModel)
            
            Spacer()

            // 디버깅 정보 영역
            #if DEBUG
            VStack(alignment: .leading, spacing: 12) {
                // Header with toggle
                HStack {
                    Text("🔍 Health Data Debug")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                if isExpanded {
                    VStack(spacing: 16) {
                        // Data Sources Status
                        DataSourcesSection(viewModel: viewModel)
                        
                        // Current Metrics
                        CurrentMetricsSection(viewModel: viewModel)
                        
                        // Permissions & Connections
                        PermissionsSection(viewModel: viewModel)
                        
                        // Real-time Data
                        RealTimeDataSection(viewModel: viewModel)
                        
                        // System Info
                        SystemInfoSection(viewModel: viewModel)
                        
                        // Legacy debug button
                        Button(action: {
                            viewModel.printDebugStatus()
                        }) {
                            Text("전체 디버그 정보 출력")
                                .font(.caption)
                                .padding(8)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
            .padding()
            .background(Color.black.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            #endif
        }
    }
}

// DEBUG 모드에서만 뷰를 표시하기 위한 View extension
extension View {
    @ViewBuilder func visibleInDebug() -> some View {
        #if DEBUG
        self
        #else
        EmptyView()
        #endif
    }
}

// MARK: - Data Sources Section
struct DataSourcesSection: View {
    @ObservedObject var viewModel: RunningViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("📡 Data Sources")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(DataSourceType.allCases, id: \.self) { sourceType in
                    DataSourceCard(
                        sourceType: sourceType,
                        isActive: viewModel.activeDataSources.contains(sourceType),
                        viewModel: viewModel
                    )
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(8)
    }
}

struct DataSourceCard: View {
    let sourceType: DataSourceType
    let isActive: Bool
    @ObservedObject var viewModel: RunningViewModel
    
    private var statusColor: Color {
        isActive ? .green : .red
    }
    
    private var statusText: String {
        isActive ? "Active" : "Inactive"
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: sourceType.iconName)
                    .foregroundColor(statusColor)
                    .font(.caption)
                
                Text(sourceType.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
            
            Text(statusText)
                .font(.caption2)
                .foregroundColor(statusColor)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(statusColor.opacity(0.1))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(statusColor.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Current Metrics Section
struct CurrentMetricsSection: View {
    @ObservedObject var viewModel: RunningViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("📊 Current Metrics")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                MetricCard(title: "Heart Rate", 
                          value: "\(viewModel.currentMetrics.heartRate) BPM",
                          icon: "heart.fill",
                          color: .red)
                
                MetricCard(title: "Cadence", 
                          value: "\(viewModel.currentMetrics.cadence) SPM",
                          icon: "figure.run",
                          color: .blue)
                
                MetricCard(title: "Distance", 
                          value: String(format: "%.2f km", viewModel.currentMetrics.distance / 1000),
                          icon: "location.fill",
                          color: .green)
                
                MetricCard(title: "Speed", 
                          value: String(format: "%.1f km/h", viewModel.currentMetrics.speed),
                          icon: "speedometer",
                          color: .orange)
                
                MetricCard(title: "Pace", 
                          value: viewModel.currentMetrics.pace.formatted,
                          icon: "timer",
                          color: .purple)
                
                MetricCard(title: "Calories", 
                          value: String(format: "%.0f kcal", viewModel.currentMetrics.calories),
                          icon: "flame.fill",
                          color: .red)
            }
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .cornerRadius(8)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Text(value)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(color)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - Permissions Section
struct PermissionsSection: View {
    @ObservedObject var viewModel: RunningViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🔐 Permissions & Connections")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(spacing: 6) {
                PermissionRow(
                    title: "HealthKit Authorization",
                    isGranted: viewModel.isHealthKitAuthorized,
                    icon: "heart.circle"
                )
                
                PermissionRow(
                    title: "Location Permission",
                    isGranted: viewModel.locationAuthStatus.contains("허용"),
                    icon: "location.circle"
                )
                
                PermissionRow(
                    title: "Apple Watch Connected",
                    isGranted: viewModel.isWatchConnected,
                    icon: "applewatch"
                )
                
                // Location Accuracy
                HStack {
                    Image(systemName: "location.magnifyingglass")
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    
                    Text("GPS Accuracy")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(String(format: "%.1f m", viewModel.locationAccuracy))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.locationAccuracy < 10 ? .green : 
                                       viewModel.locationAccuracy < 20 ? .orange : .red)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.05))
        .cornerRadius(8)
    }
}

struct PermissionRow: View {
    let title: String
    let isGranted: Bool
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isGranted ? .green : .red)
                .frame(width: 20)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(isGranted ? "✅ Granted" : "❌ Denied")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(isGranted ? .green : .red)
        }
    }
}

// MARK: - Real-time Data Section
struct RealTimeDataSection: View {
    @ObservedObject var viewModel: RunningViewModel
    @State private var refreshCount = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("🔄 Real-time Data")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("Updates: \(refreshCount)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 4) {
                DataRow(label: "Tracking Active", 
                        value: viewModel.unifiedDataManager.isTrackingActive ? "Yes" : "No",
                        color: viewModel.unifiedDataManager.isTrackingActive ? .green : .red)
                
                DataRow(label: "Running State", 
                        value: "\(viewModel.appState.runningState)",
                        color: .blue)
                
                DataRow(label: "Elapsed Time", 
                        value: String(format: "%02d:%02d:%02d", 
                                    viewModel.elapsedTime.hours,
                                    viewModel.elapsedTime.minutes,
                                    viewModel.elapsedTime.seconds),
                        color: .purple)
                
                DataRow(label: "Segment Count", 
                        value: "\(viewModel.currentSegmentCount)",
                        color: .orange)
                
                DataRow(label: "Last Update", 
                        value: DateFormatter.timeOnly.string(from: Date()),
                        color: .gray)
            }
        }
        .padding()
        .background(Color.purple.opacity(0.05))
        .cornerRadius(8)
        .onAppear {
            startRefreshTimer()
        }
    }
    
    private func startRefreshTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            refreshCount += 1
        }
    }
}

struct DataRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

// MARK: - System Info Section
struct SystemInfoSection: View {
    @ObservedObject var viewModel: RunningViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ℹ️ System Info")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(spacing: 4) {
                DataRow(label: "Device", 
                        value: isSimulator ? "Simulator" : "Physical Device",
                        color: isSimulator ? .orange : .green)
                
                DataRow(label: "iOS Version", 
                        value: UIDevice.current.systemVersion,
                        color: .blue)
                
                DataRow(label: "Debug Mode", 
                        value: "Enabled",
                        color: .red)
                
                if let debugInfo = viewModel.unifiedDataManager.getDebugInfo().components(separatedBy: "\n").first {
                    DataRow(label: "Manager Status", 
                            value: debugInfo.isEmpty ? "Ready" : "Active",
                            color: .green)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
    
    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}

// MARK: - Extensions
extension DateFormatter {
    static let timeOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter
    }()
}
