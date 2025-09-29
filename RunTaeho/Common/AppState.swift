import SwiftUI

enum ViewState {
    case Loading
    case Loaded
    // case None
}

enum RunningState {
    case Stopped
    case Running
    case Paused
    case Finished
}

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var viewState: ViewState = .Loading
    @Published var runningState: RunningState = .Stopped
    
    private init() {}
    
    func setViewState(_ state: ViewState) {
        DispatchQueue.main.async {
            self.viewState = state
        }
    }

    func setRunningState(_ state: RunningState) {
        DispatchQueue.main.async {
            self.runningState = state
        }
    }
} 
