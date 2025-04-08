//
//  UnityBridge.swift
//  RunTaeho
//
//  Created by Hong Taeho on 2/7/25.
//

import Foundation
import UIKit
import UnityFramework

class UnityBridge: UIResponder, UIApplicationDelegate, UnityFrameworkListener {
    private static var instance: UnityBridge?

    /// UnityFramework instance
    private let ufw: UnityFramework

    /// UnityFramework root view
    public var view: UIView? { ufw.appController()?.rootView }

    public static func getInstance() -> UnityBridge {
        if UnityBridge.instance == nil {
            UnityBridge.instance = UnityBridge()
        }
        return UnityBridge.instance!
    }

    /// Loads the UnityFramework  from the bundle path
    ///
    /// - Returns: The UnityFramework instance
    private static func loadUnityFramework() -> UnityFramework? {
        let bundlePath: String = Bundle.main.bundlePath + "/Frameworks/UnityFramework.framework"
        let bundle = Bundle(path: bundlePath)
        if bundle?.isLoaded == false {
            bundle?.load()
        }

        let ufw = bundle?.principalClass?.getInstance()
        if ufw?.appController() == nil {
//            let machineHeader = UnsafeMutablePointer<MachHeader>.allocate(capacity: 1)
//            machineHeader.pointee = _mh_execute_header
//            ufw!.setExecuteHeader(machineHeader)
            let machineHeader = #dsohandle.assumingMemoryBound(to: MachHeader.self)
            ufw?.setExecuteHeader(machineHeader)
        }
        return ufw
    }

    override internal init() {
        ufw = UnityBridge.loadUnityFramework()!
        ufw.setDataBundleId("com.unity3d.framework")
        super.init()

        ufw.register(self)

        ufw.runEmbedded(withArgc: CommandLine.argc, argv: CommandLine.unsafeArgv, appLaunchOpts: nil)
    }

    /// Notifies the UnityFramework to show the window, and append the Unity view
    /// to the given controller
    ///
    /// - Parameter controller: Controller that will host the Unity view
    public func show(controller: UIViewController) {
        ufw.showUnityWindow()
        if let view = self.view {
            controller.view?.addSubview(view)
        }
    }

    /// Unloads the Unity framework
    ///
    /// ## Notes
    ///
    /// * Unloading doesn't seem to free memory, or it's not picked up by the XCode dev tools.
    /// * Unloading isn't synchronous, and this object will be notified in the `unityDidUnload` method
    public func unload() {
        ufw.unloadApplication()
    }

    /// Triggered by Unity via `UnityFrameworkListener` when the framework unloaded
    internal func unityDidUnload(_: Notification!) {
        ufw.unregisterFrameworkListener(self)
        UnityBridge.instance = nil
    }
}
